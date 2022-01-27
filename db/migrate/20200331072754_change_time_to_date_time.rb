class ChangeTimeToDateTime < ActiveRecord::Migration[5.2]
  def change
    remove_column :available_days, :start_time
    remove_column :available_days, :end_time
    remove_column :available_slots, :start_time
    remove_column :available_slots, :end_time

    add_column :available_days, :start_time, :datetime
    add_column :available_days, :end_time, :datetime
    add_column :available_slots, :start_time, :datetime
    add_column :available_slots, :end_time, :datetime
  end
end
