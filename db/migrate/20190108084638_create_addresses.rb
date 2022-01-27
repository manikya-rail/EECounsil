class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.integer :user_id
      t.string :street_address
      t.string :city
      t.string :state
      t.string :country
      t.integer :zip

      t.timestamps
    end
  end
end
