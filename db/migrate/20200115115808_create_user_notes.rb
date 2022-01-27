class CreateUserNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :user_notes do |t|
      t.integer :recipient_id
      t.integer :patient_id
      t.integer :therapist_id
      t.string :action
      t.string :content

      t.timestamps
    end
  end
end
