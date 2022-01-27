class PatientPackagePlan < ApplicationRecord
  has_many :schedules, dependent: :destroy
  belongs_to :patient_package

  enum plan_type: {video: 0, text: 1}
  enum interval: {day: 0, week: 1, month: 2}

  validates :patient_package_id, :plan_type, :interval, :quantity,
            :completed_count, presence: true
end
