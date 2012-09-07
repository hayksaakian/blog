class ListingsController < ApplicationController
	def index
    @dealer = Dealer.find(params[:dealer_id])
    @listings = @dealer.listings.where(:status => "Active")
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

	def new
    @dealer = Dealer.find(params[:dealer_id])
	  @listing = @dealer.listings.new

	  respond_to do |format|
	    format.html  # new.html.erb
	    format.json  { render :json => @listing }
	  end
	end

	def create
    @dealer = Dealer.find(params[:dealer_id])
	  @listing = @dealer.listings.new(params[:listing])
		respond_to do |format|
			if @listing.save
	      format.html  { redirect_to(@dealer,
	                    :notice => 'Listing was successfully created.') }
	      format.json  { render :json => @dealer,
		                    :status => :created, :location => @dealer }
	    else
		    format.html  { render :action => "new" }
	      format.json  { render :json => @dealer.errors,
	                    :status => :unprocessable_entity }
	    end
    end
	end

	def edit
    @dealer = Dealer.find(params[:dealer_id])
    @listing = @dealer.listings.find(params[:id])
	end

	def update
    @dealer = Dealer.find(params[:dealer_id])
    @listing = @dealer.listings.find(params[:id])

		if @listing.update_attributes(params[:listing])
			redirect_to posts_path, :notice => "Listing successfully updated."
		else
			render "edit"
		end
	end

	def update_individual
		#things
		@listings_to_edit = @listings.any_in(id: params[:listing_ids])

	end

	def mark_sold
    @dealer = Dealer.find(params[:dealer_id])
    @listing = @dealer.listings.find(params[:id])
    #@listing.update_attribute(:status, "Sold")
    respond_to do |format|
			format.html #{ redirect_to(:action => 'index') }
			format.js
		end
  end

  def sold_multiple
  	#Listing.any_in(id: params[:listing_ids]).update_all(status: "Sold")
  	#@dealer.listings.any_in(id: params[:listing_ids]).update_all(status: "Sold")
  	#@listings.any_in(id: params[:listing_ids]).update_all(status: "Sold")

  	respond_to do |format|
  		format.html
  		format.js
  	end
  end

	def destroy
    @dealer = Dealer.find(params[:dealer_id])
    @listing = @dealer.listings.find(params[:id])
    #UNCOMMENT BELOW TO ENABLE DESTROY
    @listing.destroy
    respond_to do |format|
			format.html #{ redirect_to dealer_path(@dealer) }
			format.js
		end
  end

  def destroy_multiple
  	#Listing.any_in(id: params[:listing_ids]).destroy_all
  	#@dealer.listings.any_in(id: params[:listing_ids]).destroy_all
  	#@listings.any_in(id: params[:listing_ids]).destroy_all
  	@deleted_ids = params[:listing_ids]
  	respond_to do |format|
  		format.html
  		format.js
  	end
  end
end
