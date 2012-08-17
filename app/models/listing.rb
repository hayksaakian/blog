# encoding: utf-8
require 'hpricot'
class Listing
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers
  mount_uploader :snapshot, SnapshotUploader
  belongs_to :dealer
  has_many :pictures

  # attr_accessor :reject_list
  #require File.join(Rails.root, "lib", "screencap_job")
  #Mongoid::Document::ClassMethods.send(:include, ScreencapJob)


  #field :title, :type => String

  def campaign_number
    self.dealer.campaign_number
  end
  def errlog
    "!Enabled{Yes}"
  end
  def numeral_id
    self.id.to_s.to_i(16)
  end
  def contact_number
    self.dealer.contact_number
  end
  def title
    "!random{★| ♦| ▲ | ▶ | ▆| } "+self.modelyear+" "+self.make+" "+self.model+" "+self.trim+"!random{*EZ Financing Bad Credit No Credit OK* | *Amazing Clean Vehicle EZ Financing Options *|*Best Deals in Town Easy Financing Options* }"
  end
  def city
    "!city{309}"
  end
  def cat
    "!category{32}"
  end
  def age
    self.price
  end
  def locat
    self.location
  end
  def rand_hexes(quantity=10)
    s = ""
    while quantity > 0  do
      quantity -= 1
      length = [*4..7].sample
      s += " "+((0..length).map{rand(256).chr}*"").unpack("H*")[0][0,length]
    end
    s
  end

  def dealer_name
    self.dealer.name
  end

  def dealer_contact_url
    self.dealer.contact_url
  end

  def dealer_banner_url
    self.dealer.banner_url
  end

  def main_credit_template_img_src
    MyConstants::CREDIT_IMG_SRC
  end

  def main_contact_template_img_src
    MyConstants::CONTACT_IMG_SRC
  end

  def main_landing_url
    MyConstants::MAIN_LANDING_URL
  end

  def main_footer_img_src
    MyConstants::MAIN_FOOTER_IMG_SRC
  end

  def location
    self.dealer.location
  end

  field :body, :type => String, :default => "<h1>html is not ready yet</h1>"

  # field :reject_list, type: Array, default: [
  #   "reject_list",
  #   "title", 
  #   "location", 
  #   "body", 
  #   "images", 
  #   "pictures", 
  #   "image_locations", 
  #   "snapshot"]

  def footer_text
    ki = self.attributes
    #MOVE THIS TO A CLASS VARIABLE ONCE YOU FIGURE OUT HOW
    rlist = [
    "updated_at",
    "created_at",
    "optiontext",
    "dealer_id",
    "_id",
    "reject_list",
    "title", 
    "location", 
    "body", 
    "images", 
    "pictures", 
    "image_locations", 
    "snapshot"]
    kj = ki.reject { |k, v| rlist.include?(k.to_s) }
    kj.map{|k,v| "#{v}"}.join(', ')
  end

  def footer_text_hash
    ki = self.attributes
    #MOVE THIS TO A CLASS VARIABLE ONCE YOU FIGURE OUT HOW
    rlist = [
    "description",
    "created_at",
    "optiontext",
    "dealer_id",
    "_id",
    "reject_list",
    "title", 
    "location", 
    "body", 
    "images", 
    "pictures", 
    "image_locations", 
    "snapshot"]
    kj = ki.reject { |k, v| rlist.include?(k.to_s) }
    kj
  end

  field :vin, :type => String
  field :stocknumber, :type => String
  field :make, :type => String
  field :model, :type => String
  field :modelyear, :type => String
  field :trim, :type => String
  field :bodystyle, :type => String
  field :mileage, :type => String
  field :enginedescription, :type => String
  field :cylinders, :type => String
  field :fueltype, :type => String
  field :transmission, :type => String
  field :price, :type => String
  field :exteriorcolor, :type => String
  field :interiorcolor, :type => String
  field :optiontext, :type => String
  field :description, :type => String
  field :images, :type => String

  field :image_locations, :type => Array, :default => []

  after_save :get_images

 # field :urltoget, :type => String, :default => Rails.root + listing_path(self)

  def take_snapshot(id)
    listing = Listing.find(id)
    file = File.new("#{Rails.root}/tmp/#{Process.pid}_snapshot_#{self.id}",'wb')
    #s = root_url+'404'
    #HACK due to being unable to describe absolute urls on localhost
    #s should point to the url of the listing we want to take a snapshot of
    #s = "http://localhost:3000" + listing_path(listing)
    s = listing_url(listing)
    #the above should point to the to-be screencapped view
    file.write(IMGKit.new(s).to_png)
    file.flush
    listing.snapshot = file
    listing.save
    listing.delay.get_html_body(id)
  end

  def get_html_body(id)
    listing = Listing.find(id)
    doc = open(cl_listing_url(listing)) { |f| Hpricot(f) }
    listing.body = doc.to_html
    listing.save
  end

  protected
  def get_images
    if self.image_locations.empty?
      self.image_locations = ['YOU FUCKED UP, BRO.']
      self.image_locations = self.images.split(',')
      self.image_locations.each do |location|
        i = self.pictures.new
        i.get_image(location)
        i.save
      end
      self.save
      self.delay.take_snapshot(self.id)
    end
  end
end