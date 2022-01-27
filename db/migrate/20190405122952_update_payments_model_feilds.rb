class UpdatePaymentsModelFeilds < ActiveRecord::Migration[5.2]
  def change
    rename_column :payments, :patient_id, :paid_by
    remove_column :payments, :package_id, :integer
    add_column :payments, :paid_to, :integer
    add_column :payments, :paid_for, :integer
  end
end
