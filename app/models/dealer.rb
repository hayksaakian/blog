class Dealer
  include Mongoid::Document
  attr_accessible :raw_text
  mount_uploader :raw_text, RawTextUploader

  field :json_data, :type => Hash

	def convert
		json_data = FasterCSV.parse(raw_text).to_json
	end

  #has_many :listings, :dependent => :destroy
end