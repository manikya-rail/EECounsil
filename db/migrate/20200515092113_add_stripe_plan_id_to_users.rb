class AddStripePlanIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_plan_id, :string
  end
end
