class AddTimePeriodToPaymentPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_plans, :time_period, :string
  end
end
