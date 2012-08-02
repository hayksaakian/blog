require 'csv'
require 'json'

class Post
  include Mongoid::Document
  require "csv-to-json/version"
  attr_accessible :title, :content, :raw_text
  field :title, :type => String
  field :content, :type => String
  field :raw_text

  mount_uploader :raw_text, RawTextUploader

  field :json_data, :type => Hash

  def self.convert(p)
    logger.info("the url: "+p.raw_text.path)
    pth = p.raw_text.path
    csv_table = CSV.table(pth)
    list = []
    csv_table.each do |row|
      entry = {}
      csv_table.headers.each do |header|
        entry[header] = row[header]
      end
      list << entry
    end
    p.json_data = JSON.pretty_generate(list)
    p.save

    list.each do |l|
      s = l.as_json

      ls = p.listings.new
      ls.update_attributes(s)
    end
  end

  validates :title, :content, :presence => true
  #validates :title, :length => {:minimum => 4} 
  validates :title, :uniqueness => {:message => "sounds like a repost bro..."}
  has_many :comments, :dependent => :destroy
  has_many :listings, :dependent => :destroy
end
