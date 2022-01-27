class PatientPackage < ApplicationRecord

  has_many :patient_package_plans, dependent: :destroy

  belongs_to :package
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'

  validates :patient_id, presence: true
  validates :package_id, presence: true
  before_save :create_patient_package_plans_for_patient_package
  def create_patient_package_plans_for_patient_package
    @patient_package_plans = []
    self.package.package_plans.each do |p|
      if p.interval == 'day'
        @remaining_count = self.package.validity_in_days * p.quantity
      elsif p.interval == 'week'
        @remaining_count = ((self.package.validity_in_days/7.to_f).ceil) * p.quantity
      elsif p.interval == 'month'
        @remaining_count = ((self.package.validity_in_days/30.to_f).ceil) * p.quantity
      end
      @patient_package_plans = self.patient_package_plans << PatientPackagePlan.new(plan_type: p.plan_type,quantity: p.quantity,interval: p.interval,price_per_quantity: p.price_per_quantity,time_duration_in_hours: p.time_duration_in_hours, remaining_count: @remaining_count)
    end
  end
end
