class AddDefaultUnavailabilityColumnToAvailablity < ActiveRecord::Migration[5.2]
  def change
    add_column :availablities, :unavailable_start_time, :time
    add_column :availablities, :unavailable_end_time, :time
  end
end
