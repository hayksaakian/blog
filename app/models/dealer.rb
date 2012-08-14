require 'csv'
require 'json'
class Dealer
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :listings, :dependent => :destroy
  has_one :counter, :dependent => :destroy

  attr_accessible :name, :location, :banner_url, :contact_url, :raw_text, :contact_number

  field :name, :type => String
  field :location, :type => String
  field :contact_number, :type => String
  field :raw_text
  field :contact_url, :type => String, :default => "http://dealerbus.com/contactlegend"
  field :banner_url, :type => String, :default => "http://teslamarketing.com/cl/banner/legend-ad-head.gif"

  mount_uploader :raw_text, RawTextUploader

  field :json_data, :type => Hash
  before_save :convert
  after_save :make_listings, :make_counter

  def reset_counter
    self.counter.reset
  end

  def campaign_number
    self.counter.campaign_number
  end

  def convert
    if(self.json_data.nil?)
      logger.info("the url: "+self.raw_text.path)

      csv_table = CSV.table(self.raw_text.path)
      list = []
      csv_table.each do |row|
        entry = {}
        csv_table.headers.each do |header|
          entry[header] = row[header]
        end
        list << entry
      end
      self.json_data = list.as_json
    end
  end

  def make_counter
    self.counter = Counter.new
  end

  def make_listings
    self.json_data.each do |j|
      ls = self.listings.new
      ls.update_attributes(j)
    end
  end

  validates :name, :location, :presence => true
  validates :name, :length => {:minimum => 3} 
  validates :name, :uniqueness => {:message => "dealer name taken"}
end
