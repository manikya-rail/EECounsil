class CreatePlaceOfServiceCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :place_of_service_codes do |t|
      t.integer :code
      t.string :name
      t.timestamps
    end
  end
end
