class AddPaymentColumnsToSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :therapist_fees, :float
    add_column :schedules, :admin_fees, :float
    add_column :schedules, :paid_to_therapist, :boolean, default: false
  end
end
