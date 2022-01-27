class PaymentPlanSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :amount, :currency,:time_period, :trial_period, :stripe_plan_id, :features

  def features
    object.plan_features.map(&:feature_names)
  end
end
