class AddExpirydateToPackage < ActiveRecord::Migration[5.2]
  def change
    add_column :patient_packages, :expiry_date, :datetime
  end
end
