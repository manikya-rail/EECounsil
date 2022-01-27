class AddAndRenameColumnsInPatientPackages < ActiveRecord::Migration[5.2]
  def change
    rename_column :patient_package_plans, :patient_packages_id, :patient_package_id
    remove_column :patient_package_plans, :plan_id, :integer
    remove_column :patient_package_plans, :total_sessions_quantity, :integer
    remove_column :patient_package_plans, :remaining_session_quantity, :integer
    add_column :patient_package_plans, :plan_type, :integer
    add_column :patient_package_plans, :quantity, :integer
    add_column :patient_package_plans, :interval, :integer
    add_column :patient_package_plans, :time_duration_in_hours, :float
    add_column :patient_package_plans, :remaining_count, :integer
    add_column :patient_package_plans, :completed_count, :integer, default: 0
  end
end
