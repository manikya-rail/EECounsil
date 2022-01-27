class Package < ApplicationRecord

  validates :name, presence: true
  validates :details, presence: true
  validates :validity_in_days, presence: true
  validates :package_plans, presence: true

  has_many :package_plans, dependent: :delete_all
  accepts_nested_attributes_for :package_plans, reject_if: :all_blank, allow_destroy: true

  def as_json(patient_packages = nil)

    purchased =  patient_packages.present? ? patient_packages.include?(self.id) : nil

    {
      id: self.id,
      name: self.name,
      details: self.details,
      package_total: self.package_total,
      validity_in_days: self.validity_in_days,
      duration: self.duration,
      duration_interval: self.duration_interval,
      purchase: purchased
    }
  end
end
