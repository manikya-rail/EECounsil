class AddScheduleToPatientClaims < ActiveRecord::Migration[5.2]
  def change
    add_column :patient_claims, :schedule_id, :integer
  end
end
