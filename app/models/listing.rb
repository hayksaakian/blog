# encoding: utf-8
require 'open-uri'
class Listing
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers
  belongs_to :dealer
  has_many :pictures, :dependent => :destroy
  has_one :html_body, :dependent => :destroy
  has_one :snapshot, :dependent => :destroy

#TODO
#Dealer should be able to:
#Listing Statues:
#Active
#Archived
#Sold

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
    retval = self.dealer_name + " "+ self.location
    retval
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

  def footer_text
    kj = footer_text_hash
    rs = kj.values.join(', ')
    rs
  end

  def footer_text_hash
    ki = self.attributes
    #MOVE THIS TO A CLASS VARIABLE ONCE YOU FIGURE OUT HOW
    rlist = [
    "description",
    "url_to_screencap",
    "allow_changes",
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

#  field :image_locations, :type => Array, :default => []

  after_create :create_dependants
  after_update :update_dependants
#update price, miles

  def image_locations
    self.images.split(',')
  end

  def create_dependants
    self.image_locations.each do |location|
      p = self.pictures.create(original_url: location)
      #is save here necessary?
      p.save
    end
    s = cl_listing_url(self, :host => MyConstants::DOMAIN_NAME, :only_path => false)
    self.create_html_body(url_to_scrape: s) 
    s = listing_url(self, :host => MyConstants::DOMAIN_NAME, :only_path => false)
    self.create_snapshot(url_to_shoot: s)  
    self.snapshot.delay.make_snapshot
  end

  def update_dependants
    self.image_locations.each do |location|
      p = self.pictures.find_or_create_by(original_url: location)
      p.save
    end
#    old_pics = self.pictures.not_in(original_url: self.image_locations)
#    old_pics.destroy_all
    #self.update_attribute(:url_to_screencap, listing_url(self, :host => MyConstants::DOMAIN_NAME, :only_path => false))
    s = cl_listing_url(self, :host => MyConstants::DOMAIN_NAME, :only_path => false)
    self.html_body.update_attribute(:url_to_scrape, s)
    s = listing_url(self, :host => MyConstants::DOMAIN_NAME, :only_path => false)
    self.snapshot.update_attribute(:url_to_shoot, s)
    self.snapshot.delay.make_snapshot
  end
end
