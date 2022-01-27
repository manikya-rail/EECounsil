class CreateMediaNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :media_notes do |t|
      t.string :item
      t.integer :therapist_id
      t.integer :patient_id

      t.timestamps
    end
  end
end
