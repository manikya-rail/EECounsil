class AddPpaIdToSchedule < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :patient_package_plan_id, :integer
  end
end
