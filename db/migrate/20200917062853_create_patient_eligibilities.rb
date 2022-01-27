class CreatePatientEligibilities < ActiveRecord::Migration[5.2]
  def change
    create_table :patient_eligibilities do |t|
      t.integer :patient_id
      t.integer :therapist_id
      t.references :schedule, foreign_key: true
      t.string :control_number
      t.string :trading_service_payer_id
      t.string :eligible
      t.string :deductible
      t.string :co_pay
      t.string :co_insurance
      t.string :out_of_pocket
      t.string :claim_amount

      t.timestamps
    end
  end
end
