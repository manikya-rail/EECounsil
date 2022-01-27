class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true
      t.references :payment_plan, foreign_key: true
      t.string :status
      t.string :stripe_subscription_id

      t.timestamps
    end
  end
end
