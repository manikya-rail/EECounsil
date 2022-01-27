class AddTrailPeriodToPaymentPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_plans, :trial_period, :integer
  end
end
