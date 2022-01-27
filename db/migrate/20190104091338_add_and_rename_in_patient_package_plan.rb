class AddAndRenameInPatientPackagePlan < ActiveRecord::Migration[5.2]
  def change
    rename_column :patient_package_plans, :sessions_quantity, :total_sessions_quantity
    add_column :patient_package_plans, :remaining_session_quantity, :integer
  end
end
