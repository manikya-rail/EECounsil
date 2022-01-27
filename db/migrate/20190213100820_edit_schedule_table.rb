class EditScheduleTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :schedules, :patient_session_id, :integer
    remove_column :schedules, :patient_package_plan_id, :integer
    add_column :schedules, :schedule_date, :datetime
  end
end
