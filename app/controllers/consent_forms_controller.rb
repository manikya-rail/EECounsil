class ConsentFormsController < ApplicationController
  before_action :set_consent_form, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /consent_forms
  # GET /consent_forms.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: ConsentFormDatatable.new(params) }
    end
  end

  # GET /consent_forms/1
  # GET /consent_forms/1.json
  def show
  end

  # GET /consent_forms/new
  def new
    @consent_form = ConsentForm.new
  end

  # GET /consent_forms/1/edit
  def edit
  end

  # POST /consent_forms
  # POST /consent_forms.json
  def create
    @consent_form = ConsentForm.new(consent_form_params)
    respond_to do |format|
      if @consent_form.save
        format.html { redirect_to consent_forms_url, notice: 'Consent Form was successfully created.' }
        format.json { render :show, status: :created, location: @consent_form }
      else
        format.html { render :new }
        format.json { render json: @consent_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /consent_forms/1
  # PATCH/PUT /consent_forms/1.json
  def update
    respond_to do |format|
      if @consent_form.update(consent_form_params)
        format.html { redirect_to consent_forms_url, notice: 'Consent Form was successfully updated.' }
        format.json { render :show, status: :ok, location: @consent_form }
      else
        format.html { render :edit }
        format.json { render json: @consent_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /consent_forms/1
  # DELETE /consent_forms/1.json
  def destroy
    @consent_form.destroy
    respond_to do |format|
      format.html { redirect_to consent_forms_url, notice: 'Consent Form was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_consent_form
      @consent_form = ConsentForm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def consent_form_params
      params.require(:consent_form).permit(:name, :content)
    end
end
