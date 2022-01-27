class CreatePlanFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_features do |t|
      t.integer :plan_id
      t.integer :feature_id
      t.timestamps
    end
  end
end
