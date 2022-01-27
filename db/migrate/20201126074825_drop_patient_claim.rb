class DropPatientClaim < ActiveRecord::Migration[5.2]
  def change
    drop_table :patient_claims
  end
end
