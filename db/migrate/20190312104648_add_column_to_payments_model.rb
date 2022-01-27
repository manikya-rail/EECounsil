class AddColumnToPaymentsModel < ActiveRecord::Migration[5.2]
  def change
    remove_column :payments, :paid_by
    change_column :payments, :paid_to, :string
    add_column :payments, :patient_id, :integer
    add_column :payments, :package_id, :integer
    add_column :payments, :paid_at, :datetime
    add_column :payments, :amount_paid, :float
    add_column :payments, :transaction_id, :string
  end
end
