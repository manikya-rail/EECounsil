class PackagePlan < ApplicationRecord
  before_save :calculate_total_price
  belongs_to :package

  enum plan_type: {video: 0, text: 1}
  enum interval: {day: 0, week: 1, month: 2}

  validates :plan_type, presence: true
  validates :quantity, presence: true
  validates :interval, presence: true
  validates :price_per_quantity, presence: true
  validates :time_duration_in_hours, presence: true, if: -> { plan_type == 'video' }

  def calculate_total_price
    self.total_price = self.price_per_quantity * self.quantity * self.package.validity_in_days
  end
end
