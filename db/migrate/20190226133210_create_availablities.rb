class CreateAvailablities < ActiveRecord::Migration[5.2]
  def change
    create_table :availablities do |t|
      t.integer :therapist_id
      t.integer :by
      t.date :start_day
      t.date :end_day
      t.time :start_time
      t.time :end_time
      t.timestamps
    end
  end
end
