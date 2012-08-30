class Picture
  include Mongoid::Document
  belongs_to :listing
  attr_accessible :picture, :original_url, :remote_picture_url
  mount_uploader :picture, PictureUploader
  field :picture
  field :original_url, :type => String

  before_save :get_picture_from_original_url

  def get_picture_from_original_url
  	self.remote_picture_url = self.original_url
  end
end
