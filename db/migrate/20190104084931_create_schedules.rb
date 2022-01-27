class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.integer :therapist_id
      t.integer :patient_id
      t.integer :patient_session_id
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :status

      t.timestamps
    end
  end
end
