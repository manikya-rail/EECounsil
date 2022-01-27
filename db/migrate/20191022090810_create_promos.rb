class CreatePromos < ActiveRecord::Migration[5.2]
  def change
    create_table :promos do |t|
      t.integer :therapist_id, foreign_key: true, references: true
      t.references :promo_code, foreign_key: true
      t.boolean :active, default: false
      t.timestamps
    end
  end
end
