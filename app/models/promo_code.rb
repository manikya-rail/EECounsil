class PromoCode < ApplicationRecord
  enum promo_type: {Percentage: 0, 'Fixed Amount': 1}
  validates :code, presence: true
  validates_uniqueness_of :code
  validates :promo_type , presence: true
  validates :promo_value , presence: true
  has_many :promos, dependent: :destroy
  has_many :therapists, through: :promos, dependent: :destroy
  attr_accessor :email_ids

  validate :check_promo_value

  def check_promo_value
    if promo_type.present? && promo_type == 'Percentage'
      errors.add(:promo_value, "can't greater than 100%") if promo_value > 100
      errors.add(:promo_value, "can't be 0") if promo_value == 0
      errors.add(:duration_in_months, 'should be greater than 0') if duration_in_months.present? && duration_in_months == 0
    end
  end
end
