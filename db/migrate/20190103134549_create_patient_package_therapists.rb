class CreatePatientPackageTherapists < ActiveRecord::Migration[5.2]
  def change
    create_table :patient_package_therapists do |t|
      t.references :patient_package, foreign_key: true
      t.integer :therapist_id

      t.timestamps
    end
  end
end
