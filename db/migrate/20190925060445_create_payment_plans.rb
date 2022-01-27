class CreatePaymentPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_plans do |t|
      t.string :name
      t.text :description
      t.integer :amount
      t.string :currency
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
