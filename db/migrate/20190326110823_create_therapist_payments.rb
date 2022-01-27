class CreateTherapistPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :therapist_payments do |t|
      t.integer :therapist_id
      t.float :amount
      t.boolean :paid, default: false

      t.timestamps
    end
  end
end
