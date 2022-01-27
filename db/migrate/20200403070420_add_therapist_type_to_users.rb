class AddTherapistTypeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :therapist_type, :string
  end
end
