class AddPreAmountToPatientEligibilities < ActiveRecord::Migration[5.2]
  def change
    add_column :patient_eligibilities, :pre_amount, :string
  end
end
