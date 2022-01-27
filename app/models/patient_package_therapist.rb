class PatientPackageTherapist < ApplicationRecord
  belongs_to :patient_package
  belongs_to :therapist, class_name: 'User', foreign_key: 'therapist_id'

  validates :patient_package_id, presence: true
  validates :therapist_id, presence: true
end

