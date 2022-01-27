class CreatePatientPackages < ActiveRecord::Migration[5.2]
  def change
    create_table :patient_packages do |t|
      t.integer :patient_id
      t.references :package, foreign_key: true

      t.timestamps
    end
  end
end
