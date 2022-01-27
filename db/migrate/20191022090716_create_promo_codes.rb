class CreatePromoCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :promo_codes do |t|
      t.integer :promo_type
      t.float :promo_value
      t.string :code

      t.timestamps
    end
  end
end
