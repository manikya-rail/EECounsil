class CreateServiceCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :service_codes do |t|
      t.string :service_type_code
      t.text :description

      t.timestamps
    end
  end
end
