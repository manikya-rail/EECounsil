class CreatePayers < ActiveRecord::Migration[5.2]
  def change
    create_table :payers do |t|
      t.string :payer_id
      t.string :payer_name

      t.timestamps
    end
  end
end
