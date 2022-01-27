class AddAndRenameColumnInAvailablityModel < ActiveRecord::Migration[5.2]
  def change
    rename_column :availablities, :by, :by_period
  end
end
