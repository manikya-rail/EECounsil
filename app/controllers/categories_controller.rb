class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_category, only: [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: CategoryDatatable.new(params) }
    end
  end

  def new
    @category = Category.new
  end

  def create
    @categories = []
    category = true
    category_params[:name].each do |name|
      if name.blank?
        category = false
        break
      else
        @categories << Category.new(name: name)
      end
    end
    if category == false
      flash.now[:alert] = "Category can't be blank"
      render "new"
    else
      @categories.each(&:save)
      redirect_to categories_path
    end
  end

  def edit
  end

  def update
    if @category.update(name: params[:category][:name])
      redirect_to categories_path
    else
      flash.now[:alert] = "Category can't be blank"
      render "edit"
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html{ redirect_back fallback_location: categories_path}
      format.js
    end
  end

  private
    def find_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(name: [])
    end
end
