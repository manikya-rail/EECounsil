class CreateUserPayers < ActiveRecord::Migration[5.2]
  def change
    create_table :user_payers do |t|
      t.references :user, foreign_key: true
      t.references :payer, foreign_key: true

      t.timestamps
    end
  end
end
