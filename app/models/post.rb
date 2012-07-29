class Post
  include Mongoid::Document
  attr_accessible :title, :content
  field :title, :type => String
  field :content, :type => String
  validates :title, :content, :presence => true
  validates :title, :length => {:minimum => 4} 
  validates :title, :uniqueness => {:message => "sounds like a repost bro..."}
  has_many :comments, :dependent => :destroy
end
