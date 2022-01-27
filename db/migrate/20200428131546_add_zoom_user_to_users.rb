class AddZoomUserToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_zoom_user, :boolean, default: false
  end
end
