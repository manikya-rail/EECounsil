class AddAndRenameColumsInMessageModel < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :schedule_id, :integer
    rename_column :messages, :patient_id, :sender_id
    rename_column :messages, :therapist_id, :receiver_id
  end
end
