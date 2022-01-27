class AddOwnUrlToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :own_url, :string
  end
end
