require 'csv'
require 'json'
require 'net/ftp'
require "net/http"
require 'open-uri' 

class Dealer
  include Mongoid::Document
  include Mongoid::Timestamps
  has_and_belongs_to_many :users
  has_many :listings, :dependent => :destroy
  has_one :counter, :dependent => :destroy

  attr_accessible :name, :zip_code, :location, :full_location, :banner_url, :contact_url, :raw_text, :contact_number

  field :name, :type => String
  field :zip_code, :type => String
  field :location, :type => String
  field :full_location, :type => String
  field :contact_number, :type => String
  field :raw_text
  field :contact_url, :type => String, :default => MyConstants::DEFAULT_DEALER_CONTACT_URL
  field :banner_url, :type => String, :default => MyConstants::DEFAULT_DEALER_BANNER_URL

  mount_uploader :raw_text, RawTextUploader

  field :json_data, :type => Hash

  #CALLBACKS
  before_save :flesh_out_defaults, :convert
  after_save :domake_listings
  after_create :make_counter
  after_update :reset_counter

  def flesh_out_defaults
    if(not self.raw_text.filename == nil)
      s_filename = self.raw_text.filename.split("-")
      f_dealer_zip = MyConstants::DEFAULT_ZIP
      #from file
      if(self.name == "")
        self.name = s_filename[0].split(/(?=[A-Z])/).join(" ")
      end
      #from file
      if(self.zip_code == "")
        f_dealer_zip = s_filename[1].chomp(File.extname(s_filename[1]) )
        self.zip_code = f_dealer_zip
      end
      #from file, location, and zip
      if(self.location == "" or self.full_location == "")
        f_dealer_zip = s_filename[1].chomp(File.extname(s_filename[1]) )
        addrcomp = self.zip_to_locality(self.zip_code)
        if(self.location == "")
          self.location = addrcomp["address_components"][1]["short_name"].to_s
        end
        #from location and zip
        if(self.full_location == "")
          self.full_location = addrcomp["formatted_address"].to_s
        end
      end
      #fancify placeholder
      if self.banner_url == ""
        self.banner_url = self.banner_url + "&text=" +URI.escape(self.name)
      end
    end
  end

  def reset_counter
    self.counter.reset
  end

  def campaign_number
    self.counter.campaign_number
  end

  def self.poll_ftp
    ftp = Net::FTP.new(MyConstants::FTP_SERVER)
    ftp.login(MyConstants::FTP_USERNAME, MyConstants::FTP_PASS)
    files = ftp.chdir('www/feeds/carsforsale')
    files = ftp.nlst
    irl_files = []
    files.each do |filename|
      if filename.include?("-") and filename.include?(".txt") or filename.include?(".csv")
        #self.delay.procsss
        irl_files.push(filename)
      end
    end
    options = 
    { headers:           true,
      converters:        :numeric,
      header_converters: :symbol }

    retval = "\n"

    irl_files.each do |filename|
      file = ftp.gettextfile(filename, nil)
      delay.make_dealer_from_file(filename, file, options)
      retval =  retval + filename+"#" + "\n" 
    end
    ftp.close
    retval
  end

  def self.make_dealer_from_file(filename, file, options)
    arr = filename.split("-")
    dealer_name = arr[0].split(/(?=[A-Z])/).join(" ")
    zip = arr[1].chomp(File.extname(arr[1]) )

    a_dealer = Dealer.find_or_initialize_by(name: dealer_name, zip_code: zip)
    tfile = Tempfile.new(["#{Process.pid}_raw_text_viaftp_#{a_dealer.id}", 'csv'], '/tmp', :encoding => 'ascii-8bit')
    tfile.write(file)
    a_dealer.raw_text = tfile
    a_dealer.save
  end

  def zip_to_locality(zip)
    url = MyConstants.MAKE_GEOCODING_URL(zip)
    response = Net::HTTP.get(url)
    json_resp = JSON.parse(response)
    if json_resp["status"] == "OK"
      json_resp["results"][0]
    else
      json_resp["status"]
    end
  end

  def csvfile_tojson(csv_table)
    list = []
    csv_table.each do |row|
      entry = {}
      csv_table.headers.each do |header|
        entry[header] = row[header]
      end
      list << entry
    end
    list.as_json
  end

  def convert
    if(self.json_data.nil? and not self.raw_text == nil)
      csv_table = CSV.table(self.raw_text.path)
      self.json_data = self.csvfile_tojson(csv_table)
    end
  end

  def make_counter
    self.counter = Counter.new
  end

  def make_listings
    self.json_data.each do |json_source|
      self.delay.make_one_listing(json_source)
    end
  end

  def make_one_listing(json_source)
    ls = self.listings.find_or_initialize_by(vin: json_source["vin"])
    ls.update_attributes(json_source)
  end

  def domake_listings
    self.delay.make_listings
  end

  validates :contact_number, :presence => true
  validates :contact_number, :length => {:minimum => 7} 
  validates :contact_number, :uniqueness => {:message => "phone number name taken"}
end