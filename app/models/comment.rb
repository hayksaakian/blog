class Comment
  include Mongoid::Document
  belongs_to :post
  attr_accessible :body, :name
  field :body, :type => String
  field :name, :type => String
end
