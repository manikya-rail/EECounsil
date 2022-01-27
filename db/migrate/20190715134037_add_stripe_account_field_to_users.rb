class AddStripeAccountFieldToUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :stripe_connect_account_id, :string
  	add_column :users, :stripe_bank_account_id, :string
  end
end
