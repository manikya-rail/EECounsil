class ChangeStatusTypeInSchedules < ActiveRecord::Migration[5.2]
  def change
    change_column :schedules, :status, :string
  end
end
