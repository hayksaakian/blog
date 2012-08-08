class Listing
  include Mongoid::Document
  include Mongoid::Timestamps
  mount_uploader :snapshot, SnapshotUploader

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
  # set_callback(:update, :after) do |document|
  #   document.get_images(document)
  # end

      

  # def take_snapshot
  #   file = Tempfile.new(["template_#{sel.id.to_s}", 'png'], 'tmp', :encoding => 'ascii-8bit')
  #   file.write(IMGKit.new("http://google.com").to_png)
  #   file.flush
  #   sel.snapshot = file
  #   sel.save
  #   file.unlink
  # end

  protected
  def get_images
    if self.image_locations.empty?
      self.image_locations = ['derp']
      self.image_locations = self.images.split(',')
      self.save
      self.image_locations.each do |location|
        i = self.pictures.new
        i.get_image(location)
        i.save
      end
     
      # file = File.new("#{Rails.root}/tmp/websnap_#{self.id}",'w')
      # snap = WebSnap::Snapper.new('http://images.google.com', :format => 'png')
      # snap.to_file(file.path)
      # #file.flush
      # self.snapshot = file
      # #file.unlink
      # self.save!
      # # snap = WebSnap::Snapper.new('http://google.com', :format => 'png')
      # # file = snap.to_file('websnap_template_#{self.id.to_s}')
      #

      file = Tempfile.new(["template_#{self.id.to_s}", 'png'], 'tmp', :encoding => 'ascii-8bit')
      file.write(IMGKit.new('http://www.google.com').to_png)
      file.flush
      self.snapshot = file
      self.save
      file.unlink

    end
  end
end
