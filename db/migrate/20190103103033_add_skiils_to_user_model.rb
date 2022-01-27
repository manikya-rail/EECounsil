class AddSkiilsToUserModel < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :skills, :text
  end
end
