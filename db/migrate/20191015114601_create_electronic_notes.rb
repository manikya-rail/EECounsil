class CreateElectronicNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :electronic_notes do |t|
      t.integer :video_call_id
      t.string :content

      t.timestamps
    end
  end
end
