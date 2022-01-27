class AddScheduleAlertTimeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :schedule_alert_time, :integer
  end
end
