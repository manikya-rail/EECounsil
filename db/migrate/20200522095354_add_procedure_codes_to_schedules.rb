class AddProcedureCodesToSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :procedure_code_id, :integer
  end
end
