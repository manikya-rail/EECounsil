class CreateScheduleCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :schedule_charges do |t|
      t.string :status
      t.references :schedule, foreign_key: true
      t.string :description
      t.string :charge_id
      t.string :transfer_id
      t.integer :therapist_id
      t.integer :patient_id

      t.timestamps
    end
  end
end
