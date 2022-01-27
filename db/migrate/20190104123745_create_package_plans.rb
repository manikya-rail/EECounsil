class CreatePackagePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :package_plans do |t|

      t.references :package, foreign_key: true
      t.integer :plan_type
      t.integer :quantity, default: 1
      t.integer :interval
      t.integer :price_per_quantity
      t.integer :total_price
      t.float   :time_duration_in_hours

      t.timestamps
    end
  end
end
