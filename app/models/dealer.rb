require 'csv'
require 'json'
require 'net/ftp'
require "net/http"
require 'open-uri' 

class Dealer
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :listings, :dependent => :destroy
  has_one :counter, :dependent => :destroy

  attr_accessible :name, :location, :banner_url, :contact_url, :raw_text, :contact_number

  field :name, :type => String
  field :location, :type => String
  field :full_location, :type => String
  field :contact_number, :type => String, :default => "2065551234"
  field :raw_text
  field :contact_url, :type => String, :default => "http://dealerbus.com/contactlegend"
  field :banner_url, :type => String, :default => "http://teslamarketing.com/cl/banner/legend-ad-head.gif"

  mount_uploader :raw_text, RawTextUploader

  field :json_data, :type => Hash

  #CALLBACKS
  before_save :convert
  after_save :make_listings, :make_counter

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
    zip = arr[1]
    addrcomp = Dealer.zip_to_locality(zip)

    a_dealer = Dealer.find_or_initialize_by(name: dealer_name, location: addrcomp["address_components"][1]["short_name"])
    a_dealer.full_location = addrcomp.to_s
    tfile = Tempfile.new(["#{Process.pid}_raw_text_viaftp_#{a_dealer.id}", 'csv'], '/tmp', :encoding => 'ascii-8bit')
    tfile.write(file)
    a_dealer.raw_text = tfile
    a_dealer.location = addrcomp["address_components"][1]["short_name"]
    a_dealer.save
  end

  def self.zip_to_locality(zip)
    url = 'http://maps.googleapis.com/maps/api/geocode/json?address='+zip.to_s+'&sensor=true'
    url = URI.parse(url)
    response = Net::HTTP.get(url)
    json_resp = JSON.parse(response)
    if json_resp["status"] == "OK"
      result = json_resp["results"][0]
      #result["address_components"][1]["short_name"]
      result
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
    if(self.json_data.nil?)
      csv_table = CSV.table(self.raw_text.path)
      self.json_data = self.csvfile_tojson(csv_table)
    end
  end

  def make_counter
    self.counter = Counter.new
  end

  def make_listings
    self.json_data.each do |j|
      ls = self.listings.find_or_initialize_by(vin: j["vin"])
      ls.update_attributes(j)
    end
  end

  validates :name, :location, :presence => true
  validates :name, :length => {:minimum => 3} 
  validates :name, :uniqueness => {:message => "dealer name taken"}
end
