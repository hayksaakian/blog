class Listing
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :post
#  has_many :images

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
  after_save :get_images
  # set_callback(:update, :after) do |document|
  #   document.get_images(document)
  # end

  protected
  def get_images
    if self.image_locations.empty?
      self.image_locations = self.images.split(',')
      self.save
    # else
    #   logger.info("bloew the fuck up")
    #   # self.image_locations.each do |location|
    #   #   im = self.images.new
    #   #   im.remote_image_url = location
    #   #   im.save
      # end
    # elsif 
    end
      
  end
end
