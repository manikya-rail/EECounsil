class ChangeDefaultScheduleAlert < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :schedule_alert_time, :integer, default: 60
  end
  User.all.update(schedule_alert_time: 60)
end
