class Listing
  include Mongoid::Document
  include Mongoid::Timestamps
  mount_uploader :snapshot, SnapshotUploader

  #require File.join(Rails.root, "lib", "screencap_job")
  #Mongoid::Document::ClassMethods.send(:include, ScreencapJob)

  belongs_to :post
  has_many :pictures

  field :title, :type => String
  #field :price, :type => String
  field :location, :type => String
  field :body, :type => String

  field :vin, :type => String
  field :stock_number, :type => String
  field :make, :type => String
  field :model, :type => String
  field :model_year, :type => String
  field :trim, :type => String
  field :body_style, :type => String
  field :mileage, :type => String
  field :engine_description, :type => String
  field :cylinders, :type => String
  field :fuel_type, :type => String
  field :transmission, :type => String
  field :price, :type => String
  field :exterior_color, :type => String
  field :interior_color, :type => String
  field :option_text, :type => String
  field :description, :type => String
  field :images, :type => String

  field :image_locations, :type => Array, :default => []

  field :test_location, :type => String

  after_save :get_images

  field :urltoget, :type => String, :default => "http://localhost:3000/template_backup.html"

  def dothings(id)
    listing = Listing.find(id)
    file = File.new("#{Rails.root}/tmp/#{Process.pid}_snapshot_#{self.id}",'wb')
    #s = root_url+'404'
    s = listing.urltoget
    #s = "/"
    file.write(IMGKit.new(s).to_png)
    file.flush
    listing.snapshot = file
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
      #self.delay.process(self.id)
      self.delay.dothings(self.id)
    end
  end
end