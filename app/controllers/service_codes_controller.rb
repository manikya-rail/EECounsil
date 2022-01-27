class ServiceCodesController < ApplicationController
  before_action :set_service_code, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!


  def index
    respond_to do |format|
      format.html
      format.json { render json: ServiceCodeDatatable.new(params) }
    end
  end

  def show
  end

  def new
    @service_code = ServiceCode.new
  end

  def edit
  end

  def create
    @service_code = ServiceCode.new(service_code_params)
    respond_to do |format|
      if @service_code.save
        format.html { redirect_to service_codes_url, notice: 'Service Code was successfully created.' }
        format.json { render :show, status: :created, location: @service_code }
      else
        format.html { render :new }
        format.json { render json: @service_code.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @service_code.update(service_code_params)
        format.html { redirect_to service_codes_url, notice: 'Service Code was successfully updated.' }
        format.json { render :show, status: :ok, location: @service_code }
      else
        format.html { render :edit }
        format.json { render json: @service_code.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @service_code.destroy
    respond_to do |format|
      format.html { redirect_to service_codes_url, notice: 'Service Code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_code
      @service_code = ServiceCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_code_params
      params.require(:service_code).permit(:service_type_code, :description)
    end
end
