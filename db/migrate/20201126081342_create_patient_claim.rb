class CreatePatientClaim < ActiveRecord::Migration[5.2]
  def change
    create_table :patient_claims do |t|
      t.integer :therapist_id
      t.integer :patient_id
      t.integer :schedule_id
      t.string :control_number
      t.string :trading_partner_service_id
      t.string :payment_responsibility_level_code
      t.string :provider_type
      t.string :claim_codes
      t.string :patient_control_number
      t.string :place_of_service_code
      t.string :claim_frequency_code
      t.string :signature_indicator
      t.string :plan_participation_code
      t.string :accept_assignment
      t.string :release_information_code
      t.string :diagnosis_identifier
      t.string :diagnosis_code
      t.date :date_of_service_from
      t.date :date_of_service_to
      t.string :procedure_identifier
      t.string :procedure_code
      t.string :measurement_unit
      t.string :service_unit_count
      t.string :diagnosis_code_pointers
      t.string :status
      t.string :coverage_type
      t.string :patient_member_id
      t.string :patient_name
      t.string :patient_dob
      t.string :patient_gender
      t.string :patient_street_address
      t.string :patient_city
      t.string :patient_state
      t.string :patient_zip
      t.string :patient_phone
      t.string :patient_relation_to_insured
      t.string :insured_name
      t.string :insured_street_address
      t.string :insured_city
      t.string :insured_state
      t.string :insured_zip
      t.string :insured_phone
      t.string :insured_policy_number
      t.string :insured_dob
      t.string :insured_gender
      t.string :insured_plan_name
      t.string :therapist_name
      t.string :therapist_npi
      t.string :charges
      t.string :days_or_units
      t.string :therapist_ssn
      t.string :amount_paid
      t.string :patient_account_no, index: { unique: true }
      t.timestamps
    end
  end
end
