class Counter
  include Mongoid::Document
  belongs_to :dealer
  field :campaign_counter, :type => Integer, :default => 1
  field :tens_counter, :type => Integer, :default => 1
	def campaign_number
		self.tens_counter += 1
		if self.tens_counter >= 10
		  self.tens_counter = 0
		  self.campaign_counter += 1
		end
		self.save
		self.campaign_counter
	end
	def reset
		self.tens_counter = 1
		self.campaign_counter = 1
		self.save
	end
end
