class ListingsController < ApplicationController
	def create
		@listing = Listing.new
	end
end
