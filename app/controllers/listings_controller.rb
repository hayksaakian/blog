class ListingsController < ApplicationController
	def create
		@listing = Listing.new
	end
	def show
		@listing = Listing.find(params[:id])
		render :layout => false
	end
	def show_cl
    @listing = Listing.find(params[:id])
		render :template => 'listings/cl_listing', :layout => false
	end
	def show_xml
		@listing = Listing.find(params[:id])
		respond_to do |format|
		  format.html # index.html.erb
		  format.xml # index.xml.builder
		end
	end

	def destroy
    @dealer = Dealer.find(params[:dealer_id])
    @listing = @dealer.listings.find(params[:id])
    @listing.destroy
    redirect_to dealer_path(@dealer)
  end
end
