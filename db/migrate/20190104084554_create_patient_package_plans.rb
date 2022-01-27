class CreatePatientPackagePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :patient_package_plans do |t|
      t.integer :patient_packages_id
      t.integer :plan_id
      t.integer :sessions_quantity

      t.timestamps
    end
  end
end
