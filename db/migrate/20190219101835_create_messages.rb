class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.integer :patient_id
      t.integer :therapist_id
      t.string :message_content


      t.timestamps
    end
  end
end
