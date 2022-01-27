class CreateStandardNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :standard_notes do |t|
      t.text :summary
      t.string :schedule_id
      t.string :patient_id
      t.string :therapist_id
      t.boolean :draft
      t.boolean :online
      t.string :cognitive_functioning
      t.string :affect
      t.string :mood
      t.string :interpersonal
      t.string :functional_status
      t.string :risk_factor_ids
      t.text :medications
      t.text :current_functioning
      t.text :topics_discussed
      t.string :intervention_ids
      t.string :treatment_plan_objective_1
      t.string :treatment_plan_objective_2
      t.text :additional_notes
      t.text :plan
      t.string :recommendation
      t.timestamps
    end
  end
end
