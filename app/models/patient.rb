class Patient < User
  self.table_name = 'users'
  default_scope { User.joins(:roles).where('roles.name = ?', 'patient') }

  has_many :schedules, dependent: :destroy
  has_many :therapists, through: :schedules
  has_many :patient_packages
  has_many :questionnaire_answers, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :media_notes, dependent: :destroy
  has_many :schedule_charges, dependent: :destroy
  has_many :therapist_rate_per_clients
  has_many :patient_eligibilities
end
