class AddHouseNoToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :house_num, :string
  end
end
