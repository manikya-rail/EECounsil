class PlanFeature < ApplicationRecord
  belongs_to :payment_plan, foreign_key: :plan_id
  belongs_to :feature

  def feature_names
    self.feature.feature_name
  end
end
