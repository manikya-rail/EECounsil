class CreateUserInsuranceDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :user_insurance_details do |t|
      t.references :user, foreign_key: true
      t.string :npi
      t.string :tax_id
      t.string :ssn
      t.string :member_id
      t.string :group_number
      t.string :policy_number

      t.timestamps
    end
  end
end
