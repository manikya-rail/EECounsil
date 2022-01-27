class GiveDefaultValueForThePatientRelationToInsured < ActiveRecord::Migration[5.2]
  def change
    change_column :patient_claims , :patient_relation_to_insured , :string ,default: "self"
  end
end
