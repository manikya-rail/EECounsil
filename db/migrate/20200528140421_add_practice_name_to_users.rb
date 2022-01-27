class AddPracticeNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :practice_name, :string
  end
end
