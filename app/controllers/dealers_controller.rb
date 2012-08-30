class DealersController < ApplicationController
	def index
	  @dealers = current_user.dealers
	 
	  respond_to do |format|
	    format.html  # index.html.erb
	    format.json  { render :json => @dealers }
	  end
	end

	def show
	  @dealer = Dealer.find(params[:id])
	 
	  respond_to do |format|
	    format.html  # show.html.erb
	    format.json  { render :json => @dealer }
	    format.xml
	  end
	end

	def new
	  @dealer = Dealer.new
	 
	  respond_to do |format|
	    format.html  # new.html.erb
	    format.json  { render :json => @dealer }
	  end
	end

	def create
	  @dealer = Dealer.new(params[:dealer])
		@dealer.user_ids << current_user.id
		if @dealer.save
		  respond_to do |format|
	      format.html  { redirect_to(@dealer,
	                    :notice => 'Dealer was successfully added.') }
	      format.json  { render :json => @dealer,
	                    :status => :created, :location => @dealer }
		  end
    else
		  respond_to do |format|
	      format.html  { render :action => "new" }
	      format.json  { render :json => @dealer.errors,
	                    :status => :unprocessable_entity }
		  end
    end
	end

	def edit
	  @dealer = Dealer.find(params[:id])
	end

	def update_from_ftp
		str = Dealer.poll_ftp
	  respond_to do |format|
	    format.html { flash[:notice] = 'Starting update from FTP server '+str 
	    							redirect_to dealers_path}
	    format.json { head :no_content }
	  end
	end

	def update
	  @dealer = Dealer.find(params[:id])

	  respond_to do |format|
	    if @dealer.update_attributes(params[:dealer])
	      format.html  { redirect_to(@dealer,
	                    :notice => 'Dealer info was successfully updated.') }
	      format.json  { head :no_content }
	    else
	      format.html  { render :action => "edit" }
	      format.json  { render :json => @dealer.errors,
	                    :status => :unprocessable_entity }
	    end
	  end
	end

	def destroy
	  @dealer = Dealer.find(params[:id])
	  @dealer.destroy
	 
	  respond_to do |format|
	    format.html { redirect_to dealers_url }
	    format.json { head :no_content }
	  end
	end
end
