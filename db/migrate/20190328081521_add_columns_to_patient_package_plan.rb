class AddColumnsToPatientPackagePlan < ActiveRecord::Migration[5.2]
  def change
    add_column :patient_package_plans, :price_per_quantity, :integer
  end
end
