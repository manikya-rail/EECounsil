class AddColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscription_id, :string
  end
end
