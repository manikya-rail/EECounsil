class CreateUserPaymentModes < ActiveRecord::Migration[5.2]
  def change
    create_table :user_payment_modes do |t|
      t.integer :user_id
      t.integer :payment_mode
      t.string  :token
      t.timestamps
    end
  end
end
