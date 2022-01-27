class RemoveColumnsFromPaymentAndPatientPackage < ActiveRecord::Migration[5.2]
  def change
    remove_column :patient_packages, :express_token
    remove_column :patient_packages, :express_payer_id
    remove_column :payments, :paid_at
    remove_column :payments, :paid_to
  end
end
