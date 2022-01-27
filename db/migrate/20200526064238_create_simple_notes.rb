class CreateSimpleNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :simple_notes do |t|
      t.text :content
      t.string :schedule_id
      t.string :patient_id
      t.string :therapist_id
      t.boolean :draft
      t.boolean :online
      t.timestamps
    end
  end
end
