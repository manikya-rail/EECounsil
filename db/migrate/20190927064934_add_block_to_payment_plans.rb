class AddBlockToPaymentPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_plans, :block, :boolean, default: false
  end
end
