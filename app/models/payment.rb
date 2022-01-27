class Payment < ApplicationRecord
  enum paid_for: [:buying_package, :paying_therapist_fee, :to_become_a_licened_therapist, :buying_course, :subscription]
  belongs_to :user, foreign_key: "paid_by"

  def self.create_payment_details(charge, paid_for)
    payment = Payment.find(charge['metadata']['payment_id'])
    payment.update(paid_for: paid_for, status: charge['status'],transaction_id: charge['id'])
  end

  def self.create_failed_payment(charge,paid_for)
    payment = Payment.find(charge['metadata']['payment_id'])
    payment.update(paid_for: paid_for, status: charge['status'])
  end

  def self.payout_paid(payout)
    payment = Payment.find(payout['metadata']['payment_id'])
    transact_id = payout['id'].present? ? payout['id'] : ''
    payment.update(status: payout['status'], transaction_id: transact_id)
  end
end
