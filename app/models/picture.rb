class Picture
  include Mongoid::Document
  belongs_to :listing
  attr_accessible :picture, :remote_picture_url
  mount_uploader :picture, PictureUploader
  field :picture

  def get_image(location)
  	self.remote_picture_url = location
  end
end
