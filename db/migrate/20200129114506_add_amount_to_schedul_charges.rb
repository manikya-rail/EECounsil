class AddAmountToSchedulCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :schedule_charges, :amount, :integer
  end
end
