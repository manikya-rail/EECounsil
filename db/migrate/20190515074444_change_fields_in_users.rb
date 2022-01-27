class ChangeFieldsInUsers < ActiveRecord::Migration[5.2]
  def up
  	remove_column :users, :created_by_admin
  	add_column :users, :added_by, :string
  end
  def down
  	add_column :users, :created_by_admin, :boolean
  	remove_column :users, :added_by
  end
end
