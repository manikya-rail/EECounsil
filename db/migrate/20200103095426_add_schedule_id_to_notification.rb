class AddScheduleIdToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :schedule_id, :integer
    add_column :notifications, :schedule_type, :string
  end
end
