class AddNewColumnLogoToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :logo, :string
  end
end
