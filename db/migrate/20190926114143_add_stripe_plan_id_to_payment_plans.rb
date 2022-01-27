class AddStripePlanIdToPaymentPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_plans, :stripe_plan_id, :string
  end
end
