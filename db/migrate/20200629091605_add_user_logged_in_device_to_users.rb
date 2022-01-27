class AddUserLoggedInDeviceToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :current_login_device, :string
  end
end
