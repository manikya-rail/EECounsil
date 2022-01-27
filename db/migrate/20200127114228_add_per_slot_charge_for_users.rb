class AddPerSlotChargeForUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :per_slot_charges, :integer
  end
end
