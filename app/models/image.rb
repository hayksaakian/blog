class Image
  include Mongoid::Document
#  belongs_to :listing
  attr_accessible :pic
  #mount_uploader :pic, PictureUploader
  field :pic
end
