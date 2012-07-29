class PostsController < ApplicationController
	#http_basic_authenticate_with :name => "dhh", :password => "secret", :except => [:index, :show]
 
	def index
		@posts = Post.all
	end
	
	def show
		@post = Post.find(params[:id])
	end
	
	def new
		@post = Post.new
	end
	
	def create
		@post = Post.new(params[:post])

		if @post.save
			redirect_to posts_path, :notice => "dat piece of work was saved"
		else
			render "new"
		end
	end
	
	def edit
		@post = Post.find(params[:id])
	end
	
	def update
		@post = Post.find(params[:id])
		if @post.update_attributes(params[:post])
			redirect_to posts_path, :notice => "your mess was updated"
		else
			render "edit"
		end

	end

	def destroy
		@post = Post.find(params[:id])
		@post.destroy
		redirect_to posts_path, :notice => "thank the lord, your mess is gone from the world"
	end
end
