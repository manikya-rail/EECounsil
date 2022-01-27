class Api::V1::StripeController < ApplicationController

	def create_customer
	   @user = User.find_by_id(params[:user_id])
    if params['role'] == 'patient' || params["sign_up"]["role_name"] === 'patient'
      save_patient_card_details
    elsif params["sign_up"]["role_name"] === 'guest'
    	if params[:course_id]
  				@response_data = StripeChargesServices.new(params,@user).call
				if @response_data.id
					tc = TherapistCourse.where(course_id: params[:course_id], user_id: @user.id).first
					tc = TherapistCourse.new(course_id: params[:course_id], user_id: @user.id) if !tc.present?
					tc.purchased = true
          tc.save(validate: false)
				end
			end
    else
  		plan = PaymentPlan.find_by_id(params[:planId])
  		hash = {
        plan_id: plan.id,
  			stripe_plan_id: plan.stripe_plan_id,
  			stripeToken: params[:stripeToken]  ,
  			stripeEmail: params[:sign_up][:email] || params[:stripeEmail]
  		}
      if @user
  			p = PromoCode.find_by_code(params[:promo_code] || params[:sign_up][:promo_code])
  			hash[:coupon] = p.try(:code)
  			@stripe = StripeChargesServices.new(hash, @user)
  			@res = @stripe.subscribe_plan
  			@user.update(approved: true)
  		end
    end
		render json: {res: true}
	end

	def list_sources
		filtered_cards = []
		user =  User.find(params[:user][:id])
		cus_token = get_customer_token(user)
		render json: { data: get_card_details(cus_token), status: 200 }
	end

	def subscribe_plan
    user =  User.find(params[:user][:id] || params[:user][:user][:id])
    cus_token = get_customer_token(user)
		plan =  PaymentPlan.find(params[:planId])
		source = params[:sourceId]
		Stripe::Customer.update(cus_token, {default_source: source,}) if source
		@s = Stripe::Subscription.create({
      customer: cus_token,
      items: [{plan: plan.stripe_plan_id}]
    })
    user.subscription_id = @s.id
    Subscription.create(stripe_subscription_id: @s.id,user_id: user.id,payment_plan_id: plan.id, status: 'wating')
    payment = Payment.new(paid_by: user.id, amount_paid: plan.amount, transaction_id: @s.id, paid_for: :subscription, status: "waiting")
    payment.save!
    user.stripe_plan_id = plan.stripe_plan_id
    user.plan_id = plan.id
    user.save!
	end

	def create_source
		user =  User.find(params[:user_id])
		token = Stripe::Token.retrieve(params[:cardToken])
		card_fingerprint = token.card.fingerprint
    cus_token = get_customer_token(user)
		customer = Stripe::Customer.retrieve(cus_token)
		begin
			default_source = customer.default_source
			fingerprint_already_exists = customer.sources.any?{|source| source.card[:fingerprint] == card_fingerprint}
			if !fingerprint_already_exists
				source = attach_source(cus_token)
				default_source = set_to_default_source(cus_token) if params[:set_default]
				render json: { data: get_card_details(cus_token), status: 200, msg: "Card Attached" }
			else
				render json: { data: [], status: 403, msg: "Card Already Exists as Customer source" }
			end
		rescue  => e
			render json: { data: [], status: 403, msg: e.message }
		end
	end

	def detach_source
		user =  User.find(params[:stripe][:user_id])
		cus_token = get_customer_token(user)
		detach_card = Stripe::Customer.detach_source(
		  cus_token,
		  params[:stripe][:source_id]
		)
		render json: { data: get_card_details(cus_token), status: 200, msg: "Card Deleted Successfully" }
	end

	def change_sefault_source
		user =  User.find(params[:stripe][:user_id])
		cus_token = get_customer_token(user)
		params[:stripeToken] = params[:stripe][:source_id]
		set_to_default_source(cus_token)
		render json: { data: get_card_details(cus_token), status: 200, msg: "Default Card Changed Successfully" }
	end

	def subscription_history
		user =  User.find(params[:user][:id])
		cus_token = get_customer_token(user)
		customer = Stripe::Customer.retrieve(cus_token)
		render json: { data: customer.subscriptions.data, status: 200 }
	end

	def get_invoice
		invoice = Stripe::Invoice.retrieve(params[:invoice_id])
		render json: { data: invoice, status: 200 }
	end

  def upgrade_plan
    @user = User.find_by_id(params[:user][:id])
    cus_token = @user.user_payment_modes.where(payment_mode: "stripe").first.token
    plan = PaymentPlan.find_by_id(params[:planId])
    if @user
      Stripe::Subscription.delete(@user.subscription_id)
      parameters = {
        customer: cus_token,
        items: [
          {
            plan: plan.stripe_plan_id,
          },
        ],
      }
      parameters[:coupon] = @coupon if @coupon
      @s = Stripe::Subscription.create(parameters)
      Subscription.create(stripe_subscription_id: @s.id,user_id: @user.id,payment_plan_id: plan.id, status: 'new')
      @user.subscription_id = @s.id
      @user.stripe_plan_id = plan.stripe_plan_id
      @user.plan_id = plan.id
      @user.save
    end
    render json: { user: @user }
  end

	private

	def attach_source(cus_token)
		Stripe::Customer.create_source(
		  cus_token,
		  {
		    source:  params[:stripeToken],
		  }
		)
	end

	def set_to_default_source(cus_token)
		Stripe::Customer.update(
		  cus_token,
		  {
		    default_source: params[:stripeToken],
		  }
		)
	end

	def calculate_price(plan,promo_code)
  	amount = plan.amount
  	if promo_code.present?
	  	if promo_code.promo_type == "Percentage"
	  		amount = amount.to_f - (amount.to_f * promo_code.promo_value.to_f) / 100
			else
				amount = amount.to_f - promo_code.promo_value.to_f
			end
		end
		amount = 0 if amount < 0
		amount
	end


	def get_card_details(cus_token)
		customer = Stripe::Customer.retrieve(cus_token)
		default_source = customer.default_source
		cards = Stripe::Customer.list_sources(
		  cus_token,
		  {
		    limit: 10,
		    # object: 'card',
		  }
		)
		cards.each do |card|
			card.default = "Yes"
			if(card.id != default_source)
				card.default = "No"
			end
		end
		cards
	end

	def get_customer_token(user)
		user.user_payment_modes.where(payment_mode: "stripe").first.token
	end

  def save_patient_card_details
    customer = Stripe::Customer.create(
      name: params[:name],
      email: params[:stripeEmail],
      source: params[:stripeToken],
      address: {
        city: params[:billingAddress][:city],
        line1: params[:billingAddress][:street_address],
        postal_code: params[:billingAddress][:zip],
        state: params[:billingAddress][:state],
      }
    )
    @user.user_payment_modes.create(payment_mode: 0, token: customer.id)


    #     @charge = Stripe::Charge.create(
    #                     customer: "cus_GaXRXCVMAm308h",
    #                     amount: 1000,
    #                     description: "customer.email",
    #                     currency: 'usd',
    #                     on_behalf_of: "acct_1G3ilZHpyjYsYik6", ##CONNECTED_STRIPE_ACCOUNT_ID
    #                   )


    # # charge = Stripe::Charge.create({
    # #   amount: 1000,
    # #   currency: "usd",
    # #   source: "tok_visa",
    # #   on_behalf_of: "{{CONNECTED_STRIPE_ACCOUNT_ID}}",
    # #   customer: customer.id,
    # # })

    # transfer = Stripe::Transfer.create({
    #   amount: 1000,
    #   currency: "usd",
    #   source_transaction: @charge.id,
    #   destination: "acct_1G5VVWARGPOSDMHD", #CONNECTED_STRIPE_ACCOUNT_ID
    # })

  end

end
