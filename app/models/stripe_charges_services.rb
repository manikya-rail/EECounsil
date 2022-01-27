class StripeChargesServices
  DEFAULT_CURRENCY = 'usd'.freeze

  def initialize(params, user)
    @stripe_email = params[:stripeEmail]
    @stripe_token = params[:stripeToken]
    @user = user
    @coupon = params[:coupon]

    if params[:package_id].present?
      @package = params[:package_id]
      @amount   = package_amount
      @data     = {package_id: package, patient_id: user.id}
    else
      @course = params[:course_id]
      @amount  = params[:amount] || params[:course_price].to_i
      @data    = {course_id: course, therapist_id: user.id}
    end
    @payment_plan_id = params[:plan_id] if params[:plan_id]
    @plan = params[:stripe_plan_id] if params[:stripe_plan_id]
  end

  def create_plan(plan)
    @plan = Stripe::Plan.create({
      amount: plan.amount * 100,
      interval: plan.time_period,
      product: {
        name: plan.name,
      },
      currency: plan.currency,
    })
    plan.update(stripe_plan_id: @plan.id)
  end

  def call
    create_charge(find_customer_and_create_if_not_present)
  end


  def cancel_subscription
    if user.subscription_id.present?
      @s = Stripe::Subscription.delete(user.subscription_id)
      user.update(subscription_id: nil, plan_id: nil)
    end
  end

  def subscribe_plan
    parameters = {
      customer: create_customer.id,
      items: [
        {
          plan: @plan,
        },
      ],
    }
    parameters[:coupon] = @coupon if @coupon
    @s = Stripe::Subscription.create(parameters)
    Subscription.create(stripe_subscription_id: @s.id,user_id: user.id,payment_plan_id: PaymentPlan.find_by_stripe_plan_id(@plan).id, status: 'new')
    user.subscription_id = @s.id
    user.stripe_plan_id = @plan
    user.plan_id = @payment_plan_id
    user.save
  end

  private

  attr_accessor :user, :stripe_email, :stripe_token, :package , :course, :amount, :data

  def find_customer_and_create_if_not_present
    if user.user_payment_modes.find_by(payment_mode: 0).present?
      retrieve_customer(user.user_payment_modes.where(payment_mode: 0).last.token)
    else
      create_customer
    end
  end

  def retrieve_customer(stripe_token)
    Stripe::Customer.retrieve(stripe_token)
  end

  def create_customer
    customer = Stripe::Customer.create(
      email: stripe_email,
      source: stripe_token
    )
    user.user_payment_modes.create(payment_mode: 0, token: customer.id)
    customer
  end

  def create_charge(customer)
    admin = User.with_role :admin
    payment = user.payments.create!(amount_paid: amount, paid_to: admin.first.id, status: 'pending')
    data[:payment_id] = payment.id
    @charge_details = Stripe::Charge.create(
                        customer: customer.id,
                        amount: amount.to_i * 100,
                        description: customer.email,
                        currency: 'usd',
                        metadata: data,
                        statement_descriptor: user.try(:full_name)
                      )
  end

  def package_amount
    Package.find_by(id: package).package_total
  end
end
