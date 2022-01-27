class AddColumnScheduledByToSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :scheduled_by, :string, default: 'patient'
  end
end
