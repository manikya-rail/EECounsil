class RemoveColumnFromAvailableDay < ActiveRecord::Migration[5.2]
  def change
    remove_column :available_days, :unavailable_start_time, :time
    remove_column :available_days, :unavailable_end_time, :time
  end
end
