class CreateAvailableDays < ActiveRecord::Migration[5.2]
  def change
    create_table :available_days do |t|
      t.integer :availablity_id
      t.date :available_date
      t.time :start_time
      t.time :end_time
      t.time :unavailable_start_time
      t.time :unavailable_end_time
      t.timestamps
    end
  end
end
