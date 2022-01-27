class StripePayoutServices
	 
	 def initialize(therapist,amount ,admin)
    @therapist = therapist
    @admin = admin
    @amount = amount
  end

  attr_accessor :therapist, :admin, :amount
  
  def pay
  	@payout = transfer_fund(therapist)
  end  

  private

 	def transfer_fund(therapist)
 		begin
			transfer =	Stripe::Transfer.create({
				  amount: (amount.to_f * 100).to_i, #in pence
				  currency: 'usd',
				  destination: therapist.stripe_connect_account_id,
			})
			admin = User.with_role :admin
			payment = Payment.create!(amount_paid: amount, paid_by: admin.first.id, paid_to: therapist.id, paid_for: 1 ,status: 'pending')
			data = { payout_user_id: therapist.id, payment_id: payment.id }
			@payout = Stripe::Payout.create(
						{
						amount: (amount.to_f * 100).to_i, #in cents
						currency: "usd",
						destination: therapist.stripe_bank_account_id,
						metadata: data,
						},
						{ stripe_account: therapist.stripe_connect_account_id }
						)

			@payout
		rescue Stripe::StripeError => e
     	{ "error" => e.message }
    end
 	end

end
