class CreateAvailableSlots < ActiveRecord::Migration[5.2]
  def change
    create_table :available_slots do |t|
      t.references :available_day, foreign_key: true
      t.time :start_time
      t.time :end_time
      t.string :status , default: "available"
      t.integer :therapist_id
      t.references :availablity, foreign_key:  true
      t.timestamps
    end
  end
end
