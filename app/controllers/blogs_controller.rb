class BlogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @blogs = Blog.all
  end

  def new
    @blog = Blog.new
    @blog.build_media
  end

  def create
    @blog = Blog.new(get_category_params)
    if @blog.save
      redirect_to blogs_path
    else
      @blog.build_media
      render 'new'
    end
  end

  def show
    @blog = Blog.find(params[:id])
  end

  def destroy
    Blog.find(params[:id]).destroy
    redirect_to blogs_path
  end

  private
  def get_category_params
    params.require(:blog).permit(:category_id, :title, :description, media_attributes: [:item])
  end
end
