class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.integer :paid_by
      t.integer :paid_to

      t.timestamps
    end
  end
end
