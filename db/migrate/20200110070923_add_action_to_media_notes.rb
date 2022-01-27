class AddActionToMediaNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :media_notes, :recipient_id, :integer
    add_column :media_notes, :user_id, :integer
    add_column :media_notes, :action, :string
  end
end
