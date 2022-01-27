class AddExpressTokenToPatientPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :patient_packages, :express_token, :string
    add_column :patient_packages, :express_payer_id, :string
  end
end
