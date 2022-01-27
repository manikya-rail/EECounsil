class AddClaimNumberToPatientClaim < ActiveRecord::Migration[5.2]
  def change
    add_column :patient_claims, :claim_number, :string
  end
end
