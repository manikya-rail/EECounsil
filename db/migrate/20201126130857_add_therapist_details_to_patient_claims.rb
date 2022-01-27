class AddTherapistDetailsToPatientClaims < ActiveRecord::Migration[5.2]
  def change
    add_column :patient_claims, :therapist_city, :string
    add_column :patient_claims, :therapist_zip, :string
    add_column :patient_claims, :therapist_state, :string
    add_column :patient_claims, :therapist_phone, :string
  end
end
