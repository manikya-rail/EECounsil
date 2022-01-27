class ProcedureCodesController < ApplicationController
  before_action :set_procedure_code, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /procedure_codes
  # GET /procedure_codes.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: ProcedureCodeDatatable.new(params) }
    end
  end

  # GET /procedure_codes/1
  # GET /procedure_codes/1.json
  def show
  end

  # GET /procedure_codes/new
  def new
    @procedure_code = ProcedureCode.new
  end

  # GET /procedure_codes/1/edit
  def edit
  end

  # POST /procedure_codes
  # POST /procedure_codes.json
  def create
    @procedure_code = ProcedureCode.new(procedure_code_params)
    respond_to do |format|
      if @procedure_code.save
        format.html { redirect_to procedure_codes_url, notice: 'Procedure Code was successfully created.' }
        format.json { render :show, status: :created, location: @procedure_code }
      else
        format.html { render :new }
        format.json { render json: @procedure_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /procedure_codes/1
  # PATCH/PUT /procedure_codes/1.json
  def update
    respond_to do |format|
      if @procedure_code.update(procedure_code_params)
        format.html { redirect_to procedure_codes_url, notice: 'Procedure Code was successfully updated.' }
        format.json { render :show, status: :ok, location: @procedure_code }
      else
        format.html { render :edit }
        format.json { render json: @procedure_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /procedure_codes/1
  # DELETE /procedure_codes/1.json
  def destroy
    @procedure_code.destroy
    respond_to do |format|
      format.html { redirect_to procedure_codes_url, notice: 'Procedure Code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_procedure_code
      @procedure_code = ProcedureCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def procedure_code_params
      params.require(:procedure_code).permit(:code, :description, :duration)
    end
end
