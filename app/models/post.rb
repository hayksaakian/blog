require 'csv'
require 'json'

class Post
  include Mongoid::Document
#  require "csv-to-json/version"
  attr_accessible :title, :content, :raw_text
  field :title, :type => String
  field :content, :type => String
  field :raw_text

  mount_uploader :raw_text, RawTextUploader

  field :json_data, :type => Hash
  before_save :convert
  after_save :make_listings

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

  def make_listings
    self.json_data.each do |j|
      ls = self.listings.new
      ls.update_attributes(j)
    end
  end

  validates :title, :content, :presence => true
  #validates :title, :length => {:minimum => 4} 
  validates :title, :uniqueness => {:message => "sounds like a repost bro..."}
  has_many :comments, :dependent => :destroy
  has_many :listings, :dependent => :destroy
end
