class AddtherpistIdToUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :therapist_id, :integer
  end
end
