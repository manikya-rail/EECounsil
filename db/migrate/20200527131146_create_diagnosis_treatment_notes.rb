class CreateDiagnosisTreatmentNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :diagnosis_treatment_notes do |t|
      t.string :diagnosis_code_ids
      t.datetime :diagnosis_date
      t.datetime :diagnosis_time
      t.string :presenting_problem
      t.text :goal
      t.text :objective
      t.string :treatment_frequency
      t.datetime :assigned_treatment_date
      t.datetime :assigned_treatment_time
      t.string :schedule_id
      t.string :patient_id
      t.string :therapist_id
      t.boolean :treatment_notes_added
      t.timestamps
    end
  end
end
