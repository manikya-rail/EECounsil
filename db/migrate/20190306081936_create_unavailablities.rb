class CreateUnavailablities < ActiveRecord::Migration[5.2]
  def change
    create_table :unavailabilities do |t|
      t.integer :available_day_id
      t.time :unavailable_start_time
      t.time :unavailable_end_time
      t.timestamps
    end
  end
end
