class CreateMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :media do |t|
      t.integer :user_id
      t.string :item
      t.integer :mediable_id
      t.string :mediable_type

      t.timestamps
    end
  end
end
