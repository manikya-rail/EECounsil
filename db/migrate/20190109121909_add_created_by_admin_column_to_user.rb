class AddCreatedByAdminColumnToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :created_by_admin, :boolean
  end
end
