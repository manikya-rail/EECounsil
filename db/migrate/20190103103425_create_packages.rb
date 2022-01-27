class CreatePackages < ActiveRecord::Migration[5.2]
  def change
    create_table :packages do |t|
      t.string :name
      t.string :details
      t.integer :package_total
      t.integer :validity_in_days

      t.timestamps
    end
  end
end
