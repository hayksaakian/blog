# encoding: utf-8
require 'open-uri'
class Listing
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers
  mount_uploader :snapshot, SnapshotUploader
  belongs_to :dealer
  has_many :pictures

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

  field :body, :type => String, :default => "<h1>html is not ready yet</h1>"

  def footer_text
    kj = footer_text_hash
    kj.map{|k,v| "#{v}"}.join(', ')
    kj
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

#  field :image_locations, :type => Array, :default => []

  field :url_to_screencap, :type => String
  field :needs_changes, :type => Boolean, :default => true

  before_save :get_images

  def get_html_body
    s = cl_listing_url(self, :host => MyConstants::DOMAIN_NAME, :only_path => false)
    doc = Nokogiri::HTML(open(s))
    self.body = doc.at_xpath("//body").inner_html
  end

  def make_snapshot(url)
    file = Tempfile.new(["#{Process.pid}_snapshot_#{self.id}", 'png'], '/tmp', :encoding => 'ascii-8bit')
    file.write(IMGKit.new(url).to_png)
    file.flush
    self.snapshot = file
    file.unlink
    self.get_html_body
  end

  def image_locations
    self.images.split(',')
  end

  def get_images
    if self.needs_changes == true
      self.update_attribute(:needs_changes => false)
      self.image_locations.each do |location|
        self.pictures.find_or_create_by(original_url: location)
      end
      self.update_attribute (:url_to_screencap, listing_url(self, :host => MyConstants::DOMAIN_NAME, :only_path => false))
      self.delay.make_snapshot(s)
    end
  end
end
