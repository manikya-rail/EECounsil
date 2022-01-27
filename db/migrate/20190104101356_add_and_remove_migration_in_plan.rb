class AddAndRemoveMigrationInPlan < ActiveRecord::Migration[5.2]
  def change
    remove_column :plans, :type
    add_column :plans, :duration, :float
    add_column :plans, :duration_interval, :integer
    add_column :plans, :valid_days, :integer
  end
end
