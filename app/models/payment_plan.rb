class PaymentPlan < ApplicationRecord
  belongs_to :user
  validates :name, presence:  true, uniqueness: true
  validates :amount, presence: true
  validates_length_of :name, maximum: 50
  scope :unblocked,-> {where(block: false)}
  has_many :users, foreign_key: :plan_id
  has_many :plan_features, foreign_key: :plan_id
  # after_create :remove_raw_html_tags
  after_create :create_stripe_plan
  attr_accessor :feature_ids

  def create_stripe_plan
  	@stripe = StripeChargesServices.new({},self.user)
  	@stripe.create_plan(self)
  end

  def remove_raw_html_tags
    self.update!(description: description.strip)
  end
end
