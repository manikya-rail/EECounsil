class RenameAndAddColumnInPackage < ActiveRecord::Migration[5.2]
  def change
    add_column :packages, :duration, :integer
    add_column :packages, :duration_interval, :integer
  end
end
