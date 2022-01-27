class PromoCodesController < ApplicationController
  before_action :set_promo_code, only: [:show, :edit, :update, :destroy, :promos_for_therapists]

  # GET /promo_codes
  # GET /promo_codes.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: PromoCodeDatatable.new(params) }
    end
  end

  # GET /promo_codes/1
  # GET /promo_codes/1.json
  def show
  end

  # GET /promo_codes/new
  def new
    @promo_code = PromoCode.new
  end

  # GET /promo_codes/1/edit
  def edit
  end

  # POST /promo_codes
  # POST /promo_codes.json
  def create
    @promo_code = PromoCode.new(promo_code_params)

    respond_to do |format|
      if @promo_code.save
        if @promo_code.duration_in_months
          parameters = {
            duration: 'repeating',
            id: @promo_code.code,
            duration_in_months: @promo_code.duration_in_months,
          }
        else
          parameters = {
            duration: 'forever',
            id: @promo_code.code,
          }
        end
        if @promo_code.promo_type == 'Percentage'
          parameters[:percent_off] =  @promo_code.promo_value
        else
          parameters[:amount_off] =  @promo_code.promo_value.to_i * 100
          parameters[:currency] = 'usd'
        end
        coupon = Stripe::Coupon.create(parameters)
        format.html { redirect_to promo_codes_path, notice: 'Promo code was successfully created.' }
        format.json { render :show, status: :created, location: @promo_code }
      else
        format.html { render :new }
        format.json { render json: @promo_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /promo_codes/1
  # PATCH/PUT /promo_codes/1.json
  def update
    respond_to do |format|
      if @promo_code.update(promo_code_params)
        format.html { redirect_to promo_codes_path, notice: 'Promo code was successfully updated.' }
        format.json { render :show, status: :ok, location: @promo_code }
      else
        format.html { render :edit }
        format.json { render json: @promo_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /promo_codes/1
  # DELETE /promo_codes/1.json
  def destroy
    Stripe::Coupon.delete(@promo_code.code)
    @promo_code.destroy!
    respond_to do |format|
      format.html { redirect_to promo_codes_url, notice: 'Promo code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def promos_for_therapists
    @therapists = Therapist.all
  end

  def sent_promos_to_therapists
    params_hsh = params[:promo_code]
    promo_code = PromoCode.find(params_hsh[:promo_code_id])
    params_hsh[:email_ids].reject(&:empty?).each do |email|
      user = User.find_by(email: email)
      UserMailer.notify_therapist_about_promo(user, promo_code).deliver!
    end
    respond_to do |format|
      format.html { redirect_to promo_codes_url, notice: 'Promo code was sent successfully to selected therapists' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_promo_code
      @promo_code = PromoCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def promo_code_params
      params.require(:promo_code).permit(:promo_type, :promo_value, :code, :duration_in_months)
    end
end
