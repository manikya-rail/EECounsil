class GiveDefaultValueForThePreAmount < ActiveRecord::Migration[5.2]
  def change
    change_column :patient_eligibilities , :pre_amount , :string ,default: "0"
  end
end
