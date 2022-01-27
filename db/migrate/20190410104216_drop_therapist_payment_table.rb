class DropTherapistPaymentTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :therapist_payments
  end
end
