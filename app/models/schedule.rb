class Schedule < ApplicationRecord

  include AASM
  belongs_to :therapist
  belongs_to :patient
  belongs_to :patient_package_plan, optional: true
  has_many :messages, dependent: :destroy
  has_many :schedule_charges, dependent: :destroy
  has_one :electronic_note
  has_many :procedure_codes
  has_many :video_calls, dependent: :destroy
  has_many :notifications
  has_many :patient_eligibility
  before_save :add_therepist_and_admin_fee, unless: :skip_validation
  attr_accessor :skip_validation

  aasm column: 'status' do
    state :scheduled, initial: true
    state :booked
    state :canceled
    state :partial_completed
    state :completed

    event :book do
      transitions from: :scheduled, to: :booked
    end

    event :cancel do
      transitions from: [:booked, :scheduled], to: :canceled
    end

    event :partial_complete do
      transitions from: :booked, to: :partial_completed
    end

    event :complete do
      transitions from: :partial_completed, to: :completed
    end
  end

  scope :unscheduled, -> {where(starts_at: nil,ends_at: nil)}

  validates :therapist_id, presence: true
  validates :patient_id, presence: true
  validates :status, presence: true
  validate :check_user_status, unless: :skip_validation
  validate :available_in_time, unless: :skip_validation
  validate :unavailability_time, unless: :skip_validation
  validate :already_book, unless: :skip_validation

  def add_therepist_and_admin_fee
    actual_fees = patient_package_plan.price_per_quantity
    self.admin_fees = (10*actual_fees).to_f / 100.to_f
    self.therapist_fees = actual_fees - admin_fees
  end

  def unscheduled?
    self.starts_at.nil? and self.ends_at.nil?
  end

  def self.schedule_update(schedule,user,state)
    other_user = (user.roles.first.name == 'patient') ? User.find(schedule.therapist_id) : User.find(schedule.patient_id)
    # emails = [ user.email, other_user.email ]
    # emails.each do |email|
    mail_user = User.find_by(email: other_user.email)
    UserMailer.notify_user_about_schedule(schedule, user, state, other_user, user.email, mail_user).deliver_later
    # end
  end

  def self.send_appointment_alert
    puts '******Appointment alert'
    @schedules = Schedule.where(schedule_date: Date.today)
    @schedules.each do |schedule|
      therapist =  schedule.therapist
      patient = schedule.patient
      thera_time =  schedule.starts_at - (therapist.schedule_alert_time  * 60)
      patient_time = schedule.starts_at - (patient.schedule_alert_time * 60)
      if thera_time.to_s(:time) == Time.now.utc.to_s(:time)
        UserMailer.appointment_alert(therapist, patient, schedule).deliver_now
      end
      if patient_time.to_s(:time) == Time.now.utc.to_s(:time)
        UserMailer.appointment_alert(patient, therapist, schedule).deliver_now
      end
    end
  end

  def refund_charge_amount
    refund = Stripe::Refund.create({
    charge: 'ch_XpL0wrxnnmQvSEJ1exQc',
        amount: 1000,
    })
  end

  def self.send_sms_and_email_appointment_alert
    puts "****Appointment Email/SMS alert****"
    @schedules = Schedule.where(schedule_date: Date.today, status: 'booked')
    @schedules.each do |schedule|
      therapist =  schedule.therapist
      patient = schedule.patient
      usr_timezone = therapist.time_zone || 'Eastern Time (US & Canada)'
      current_time = DateTime.now.utc.strftime("%I:%M %P").to_time
      seconds = schedule.starts_at.strftime("%I:%M %P").to_time - current_time
      minutes = (seconds / 60).to_i
      puts "****Current time: #{current_time}"
      puts "*****Seconds: #{seconds}"
      if schedule.starts_at.strftime("%I:%M %P").to_time > current_time
        if minutes === therapist.schedule_alert_time
          UserMailer.appointment_reminder(therapist, patient, schedule).deliver_now
          puts '****therapist email sent'
          # msg = "You have an #{schedule.starts_at.strftime("%I:%M %P")} appointment with your patient. You may login at https://ecounsel.com to begin your session"
          # TwilioTextMessenger.new(msg, therapist.phone_number).call
        end
        if minutes === patient.schedule_alert_time
          UserMailer.appointment_reminder(patient, therapist, schedule).deliver_now
          puts '****patient email sent'
          # msg = "You have an #{schedule.starts_at.strftime("%I:%M %P")} appointment with your Licensed Therapist. You may login at https://ecounsel.com to begin your session"
          # TwilioTextMessenger.new(msg, patient.phone_number).call
        end
      end
    end
  end

  def self.schedule_charges_from_patients
    send_sms_and_email_appointment_alert
    puts '***********Schedule check******'
    @schedules = Schedule.where(schedule_date: Date.today, status: "booked", scheduled_by: 'patient')
    @schedules.each do |schedule|
      therapist =  schedule.therapist
      patient = schedule.patient
      # usr_timezone = therapist.time_zone || 'Eastern Time (US & Canada)'
      date_checked = schedule.schedule_date.strftime("%d/%m/%Y") == DateTime.now.utc.strftime("%d/%m/%Y")
      time_checked = schedule.starts_at.strftime("%H:%M %P") == DateTime.now.utc.strftime("%H:%M %P")
      puts "******Schedule Time***** #{schedule.starts_at.strftime("%H:%M %P")}"
      puts "******Current Time***** #{DateTime.now.utc.strftime("%H:%M %P")}"
      if date_checked && time_checked
        customer_token = patient.user_payment_modes.where(payment_mode: "stripe").try(:first).try(:token)
        description = "Charge against #{patient.first_name} #{patient.last_name} for Therapist: #{therapist.first_name} #{therapist.last_name}"
        if therapist.stripe_connect_account_id.present? && customer_token.present?
          patient_eligibility = PatientEligibility.find_by(patient_id: patient.id, therapist_id: therapist.id, schedule_id: schedule.id)
          if patient_eligibility.nil? || patient_eligibility.pre_amount == '0'
            slot_charge = TherapistRatePerClient.find_by(therapist_id: therapist.id, patient_id: patient.id).default_rate
          else
            slot_charge = patient_eligibility.pre_amount
          end
          charge = create_patient_charge(customer_token, therapist, description, slot_charge)
          transfer = transfer_charge_to_therapist(therapist, charge, slot_charge)
          ScheduleCharge.create(
            therapist_id: therapist.id,
            patient_id: patient.id,
            charge_id: charge.id,
            schedule_id: schedule.id,
            status: "charged",
            description: description,
            transfer_id: transfer.id,
            amount: slot_charge.to_i * 100
          )
        end
      end
    end
  end

  def self.create_patient_charge(customer_token, therapist, description, slot_charge)
    charge = Stripe::Charge.create(
            customer: customer_token,
            amount: slot_charge.to_i * 100,
            description: description,
            currency: 'usd',
            on_behalf_of: therapist.stripe_connect_account_id, ##CONNECTED_STRIPE_ACCOUNT_ID
            statement_descriptor: therapist.full_name
          )
  end

  def self.transfer_charge_to_therapist(therapist, charge, slot_charge)
    transfer = Stripe::Transfer.create({
      amount: slot_charge.to_i * 100,
      currency: "usd",
      source_transaction: charge.id,
      destination: therapist.stripe_connect_account_id, #CONNECTED_STRIPE_ACCOUNT_ID
    })
  end

  def self.check_expire_schedules
    @schedules = Schedule.where("schedule_date < ? AND status!= ? AND status!= ?", Date.today, 'canceled','completed')
    @schedules.each do |schedule|
      schedule.update(status: 'canceled')
      plan_id =  schedule.patient_package_plan_id
      patient_plan = PatientPackagePlan.find(plan_id)
      patient_plan.decrement!(:completed_count)
      patient_plan.increment!(:remaining_count)
    end
  end

  private

    def check_user_status
      if User.find(self.therapist_id).status == false || User.find(self.patient_id).status == false
        self.skip_validation = true
        errors.add(:error, "Account is inactive")
      end
    end

    def available_in_time
      therpist_availability_time = Therapist.find(self.therapist_id).available_days.find_by(available_date: self.schedule_date)
      sch_remain = PatientPackagePlan.find(self.patient_package_plan_id).remaining_count
      remain_count = (self.id).present? ? nil : sch_remain
      unless therpist_availability_time.present? && time_between(self.starts_at, therpist_availability_time.start_time, therpist_availability_time.end_time) && time_between(self.ends_at,therpist_availability_time.start_time, therpist_availability_time.end_time) && (self.id.present? ? true : self.schedule_date.to_date >= Date.today) && (self.id.present? ? true : sch_remain > 0)
        self.skip_validation = true
        if sch_remain == 0
          errors.add(:error, "Your plan limit is over")
        else
          errors.add(:error, "Therapist is not available at this time frame")
        end
      end
    end

    def unavailability_time
      therpist_availability_time = Therapist.find(self.therapist_id).available_days.find_by(available_date: self.schedule_date)
      therpist_availability_time.unavailabilities.each do |unavailability|
        if time_between(self.starts_at,unavailability.unavailable_start_time,unavailability.unavailable_end_time,) || time_between(self.ends_at,unavailability.unavailable_start_time,unavailability.unavailable_end_time) || time_outside(self.starts_at,self.ends_at,unavailability.unavailable_start_time,unavailability.unavailable_end_time)
          self.skip_validation = true
          errors.add(:error, "Therapist is not available at this time frame")
        end
      end
    end

    def already_book
      booked_schedules = Schedule.where(therapist: self.therapist_id, schedule_date: self.schedule_date)
      booked_schedule = booked_schedules.where.not(id:self.id)
      booked_schedule.each do |sch|
        if time_between(self.starts_at,sch.starts_at,sch.ends_at) || time_between(self.ends_at,sch.starts_at,sch.ends_at) || time_outside(self.starts_at, self.ends_at, sch.starts_at, sch.ends_at)
          errors.add(:error, "This time frame is already Booked")
        end
      end
    end

    def time_between(time, start_time, end_time)
      time.strftime("%H:%M").between?(start_time.strftime("%H:%M"), end_time.strftime("%H:%M"))
    end

    def time_outside(time1, time2, start_time, end_time)
      (time1.strftime("%H:%M") < start_time.strftime("%H:%M")) && (time2.strftime("%H:%M") > end_time.strftime("%H:%M"))
    end
end
