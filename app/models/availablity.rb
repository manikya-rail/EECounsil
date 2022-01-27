class Availablity < ApplicationRecord

  enum by_period: [:week, :month]
  has_many :available_days, dependent: :destroy
  belongs_to :therapist, class_name: 'User', foreign_key: 'therapist_id'
  validate :set_end_date
  validate :create_available_days_for_availablity
  # after_create :add_default_unavailablity_to_days
  attr_accessor :days

  def set_end_date
    if end_time - start_time < 3600
      errors.add(:errors, "Availability minimum 60 minute slot")
      errors.add(:errors, "Availability minimum 60 minute slot")
    end
    if unavailable_end_time && unavailable_start_time && (unavailable_end_time - unavailable_start_time <= 1800)
      errors.add(:errors, "Break time minimum 30 minute slot")
      errors.add(:errors, "Break time minimum 30 minute slot")
    end
    if by_period == 'week'
      self.end_day = start_day + 6
    else
      self.end_day = start_day + 29
    end
  end


  def create_available_days_for_availablity
    @available_days = []
    @therapist_availability = Therapist.find(self.therapist_id).available_days
    therapist_availabile_dates = @therapist_availability.pluck(:available_date)
    for i in 0..(start_day...end_day).to_a.size
        if days.present?
          if days.include?((start_day.to_date + i).wday.to_s)
            create_available_day(i,therapist_availabile_dates)
          end
        else
          unless ((start_day.to_date + i).wday == 6) || ((start_day.to_date + i).wday == 0)
            create_available_day(i,therapist_availabile_dates)
          end
        end
    end
    errors.add(:errors, "Availability already added") if @available_days.blank?
  end


  def create_available_day(k, therapist_availabile_dates)
    check_avail = therapist_availabile_dates.include?(start_day.to_date + k)
    if check_avail == false
      @available_days = self.available_days << AvailableDay.new(available_date: (start_day.to_date + k), start_time: start_time, end_time: end_time)
    else
      update_available_day(k)
    end
  end

  def update_available_day(k)
    require 'logger'
    available_slots = @therapist_availability.find_by(available_date: (start_day.to_date + k)).available_slots
    existing_start_time = available_slots.map{|ele| ele.start_time.strftime('%H:%M')}
    existing_end_time = available_slots.map{|ele| ele.end_time.strftime('%H:%M')}
    Rails.logger.info "-----available_slots---- #{available_slots.inspect}"
    Rails.logger.info "------existing strattime: #{existing_start_time}"
    Rails.logger.info "------existing endtime: #{existing_end_time}"
    Rails.logger.info "------starttime: #{start_time}"
    if !(existing_start_time.include? start_time.strftime('%H:%M'))
      @available_days = @therapist_availability.find_by(available_date: (start_day.to_date + k))
      @available_days.update!(start_time: start_time, end_time: end_time)
    end
  end

  def add_default_unavailablity_to_days
    self.available_days.each do |day|
      day.unavailabilities.create!(unavailable_start_time: unavailable_start_time.to_time, unavailable_end_time: unavailable_end_time.to_time)
    end
  end
end
