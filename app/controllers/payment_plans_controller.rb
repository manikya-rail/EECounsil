class PaymentPlansController < ApplicationController
  before_action :set_payment_plan, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /payment_plans
  # GET /payment_plans.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: PlanDatatable.new(params) }
    end
  end

  def block
    @plan = PaymentPlan.find_by_id(params[:id])
    @plan.update(block: true)
  end

  def unblock
    @plan = PaymentPlan.find_by_id(params[:id])
    @plan.update(block: false)
  end

  # GET /payment_plans/1
  # GET /payment_plans/1.json
  def show
  end

  # GET /payment_plans/new
  def new
    @payment_plan = PaymentPlan.new
    @payment_plan.plan_features.build
  end

  # GET /payment_plans/1/edit
  def edit
  end

  # POST /payment_plans
  # POST /payment_plans.json
  def create
    @payment_plan = PaymentPlan.new(payment_plan_params)
    @payment_plan.user = current_user
    respond_to do |format|
      if @payment_plan.save
        feature_ids = params[:payment_plan][:feature_ids].reject(&:empty?)
        feature_ids.each{|feature_id| PlanFeature.create!(plan_id: @payment_plan.id, feature_id: feature_id)}
        format.html { redirect_to plans_url, notice: 'Plan was successfully created.' }
        format.json { render :show, status: :created, location: @payment_plan }
      else
        format.html { render :new }
        format.json { render json: @payment_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_plans/1
  # PATCH/PUT /payment_plans/1.json
  def update
    respond_to do |format|
      if @payment_plan.update(payment_plan_params)
        update_stripe_plan
        @payment_plan.plan_features.delete_all
        feature_ids = params[:payment_plan][:feature_ids].reject(&:empty?)
        feature_ids.each{|feature_id| PlanFeature.create!(plan_id: @payment_plan.id, feature_id: feature_id)}
        format.html { redirect_to plans_url, notice: 'Plan was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment_plan }
      else
        format.html { render :edit }
        format.json { render json: @payment_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_plans/1
  # DELETE /payment_plans/1.json
  def destroy
    delete_stripe_plan
    @payment_plan.destroy
    respond_to do |format|
      format.html { redirect_to plans_url, notice: 'Plan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_plan
      @payment_plan = PaymentPlan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_plan_params
      params.require(:payment_plan).permit(:name, :description, :amount, :currency, :user_id, :trial_period, :time_period, :feature_ids)
    end

    def update_stripe_plan
      old_stripe_plan_id = @payment_plan.stripe_plan_id
      delete_stripe_plan
      plan = Stripe::Plan.create({
        amount: @payment_plan.amount * 100,
        interval: @payment_plan.time_period,
        product: {
          name: @payment_plan.name,
        },
        currency: @payment_plan.currency,
      })
      @payment_plan.update!(stripe_plan_id: plan.id)
      User.where(stripe_plan_id: old_stripe_plan_id).each{|usr| usr.update!(stripe_plan_id: plan.id)}
    end

    def delete_stripe_plan
      existing_stripe_plans = Stripe::Plan.list
      existing_stripe_plan_ids = existing_stripe_plans['data'].map(&:id)
      Stripe::Plan.delete(@payment_plan.stripe_plan_id) if existing_stripe_plan_ids.include? @payment_plan.stripe_plan_id
    end
end
