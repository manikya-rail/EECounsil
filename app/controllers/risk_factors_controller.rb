class RiskFactorsController < ApplicationController
  before_action :set_risk_factor, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /risk_factors
  # GET /risk_factors.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: RiskFactorDatatable.new(params) }
    end
  end

  # GET /risk_factors/1
  # GET /risk_factors/1.json
  def show
  end

  # GET /risk_factors/new
  def new
    @risk_factor = RiskFactor.new
  end

  # GET /risk_factors/1/edit
  def edit
  end

  # POST /risk_factors
  # POST /risk_factors.json
  def create
    @risk_factor = RiskFactor.new(risk_factor_params)
    respond_to do |format|
      if @risk_factor.save
        format.html { redirect_to risk_factors_url, notice: 'Risk Factor was successfully created.' }
        format.json { render :show, status: :created, location: @risk_factor }
      else
        format.html { render :new }
        format.json { render json: @risk_factor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /risk_factors/1
  # PATCH/PUT /risk_factors/1.json
  def update
    respond_to do |format|
      if @risk_factor.update(risk_factor_params)
        format.html { redirect_to risk_factors_url, notice: 'Risk Factor was successfully updated.' }
        format.json { render :show, status: :ok, location: @risk_factor }
      else
        format.html { render :edit }
        format.json { render json: @risk_factor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /risk_factors/1
  # DELETE /risk_factors/1.json
  def destroy
    @risk_factor.destroy
    respond_to do |format|
      format.html { redirect_to risk_factors_url, notice: 'Risk Factor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_risk_factor
      @risk_factor = RiskFactor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def risk_factor_params
      params.require(:risk_factor).permit(:title)
    end
end
