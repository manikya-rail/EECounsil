class Therapist < User
  self.table_name = 'users'
  default_scope { User.joins(:roles).where('roles.name = ?', 'therapist') }

  has_many :schedules, dependent: :destroy
  has_many :availablities, dependent: :destroy
  has_many :patients
  # , through: :schedules
  has_many :available_days, through: :availablities
  has_many :therapist_courses
  has_many :available_slots, dependent: :destroy
  has_many :promos
  has_many :promo_codes, through: :promos
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :media_notes, dependent: :destroy
  has_many :schedule_charges, dependent: :destroy
  has_many :therapist_rate_per_clients
  has_many :patient_eligibility

  def send_invite_patient_mail(invites_ary, form_ids)
    invites_ary.to_a.flatten.each do |invite_hash|
      UserMailer.patients_invite(self, invite_hash[:id], invite_hash[:default_rate], form_ids).deliver!
    end
  end

  def update_patient_default_rate(patient_id, default_rate)
    TherapistRatePerClient.find_by(therapist_id: self, patient_id: patient_id).update!(default_rate: default_rate)
  end

  def fetch_default_charge(patient_id)
    TherapistRatePerClient.find_by(therapist_id: self, patient_id: patient_id).default_rate
  end

end
