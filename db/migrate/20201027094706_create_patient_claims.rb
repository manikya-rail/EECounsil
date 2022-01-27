class CreatePatientClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :patient_claims do |t|
      t.integer :therapist_id
      t.integer :patient_id
      t.string :control_number
      t.string :trading_partner_service_id
      t.string :payment_responsibility_level_code
      t.string :provider_type
      t.string :claim_filing_code
      t.string :patient_control_number
      t.string :place_of_service_code
      t.string :claim_frequency_code
      t.string :signature_indicator
      t.string :plan_participation_code
      t.string :benefits_assgmt_certification_indicator
      t.string :release_information_code
      t.string :diagnosis_type_code
      t.string :diagnosis_code
      t.date :service_date
      t.string :procedure_identifier
      t.string :procedure_code
      t.string :measurement_unit
      t.string :service_unit_count
      t.string :diagnosis_code_pointers
      t.string :status
      t.timestamps
    end
  end
end
