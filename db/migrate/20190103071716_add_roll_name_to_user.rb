class AddRollNameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :role_name, :string
  end
end
