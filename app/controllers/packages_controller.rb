class PackagesController < ApplicationController

  after_action :set_total_price_of_package , only: [:create, :update]
  before_action :authenticate_user!
  before_action :find_package, only: [:edit, :update]
  # load_and_authorize_resource

  def index
    @packages = Package.all
  end

  def new
    @package = Package.new
  end

  def create
    @package = Package.new(package_params)
    if @package.save
      redirect_to packages_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @package.update(package_params)
      redirect_to packages_path
    else
      render "edit"
    end
  end

  private
    def package_params
      params.require(:package).permit(:name, :details, :validity_in_days, :package_total,
                                      package_plans_attributes: [:id, :package_id, :plan_type,
                                                                 :quantity, :interval,
                                                                 :time_duration_in_hours,
                                                                 :price_per_quantity, :total_price,
                                                                 :_destroy])
    end

    def find_package
      @package = Package.find(params[:id])
    end

    def set_total_price_of_package
      package_total = @package.package_plans.pluck(:total_price).compact.sum
      @package.update(package_total: package_total)
    end
end
