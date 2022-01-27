class AddScheduleIdToMediaNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :media_notes, :schedule_id, :integer
  end
end
