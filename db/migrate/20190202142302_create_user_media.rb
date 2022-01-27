class CreateUserMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :user_media do |t|
      t.integer :user_id
      t.string :item
      t.integer :media_type

      t.timestamps
    end
  end
end
