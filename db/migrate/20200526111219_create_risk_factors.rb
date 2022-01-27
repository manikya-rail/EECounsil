class CreateRiskFactors < ActiveRecord::Migration[5.2]
  def change
    create_table :risk_factors do |t|
      t.string :title
      t.timestamps
    end

    risk_factors_ary = ['None', 'Suicidal Ideation', 'Homicidal Ideation', 'Other']
    risk_factors_ary.each do |risk_factor|
      RiskFactor.create(title: risk_factor)
    end
  end
end
