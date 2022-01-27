class AvailableDay < ApplicationRecord
  belongs_to :availablity
  has_many :available_slots, dependent: :destroy
  has_many :unavailabilities, dependent: :destroy
  after_save :create_available_slots_for_available_day

  private

  def create_available_slots_for_available_day
    @available_slots = []
    @available_slots_arrays = []

    @unavailable_slots = []
    @unavailable_slots_arrays = []
    (start_time.round_off(15).to_datetime.to_i .. end_time.round_off(15).to_datetime.to_i).step(60.minutes).each do |time|
      @available_slots.push(Time.zone.at(time).rfc2822)
    end
    length = @available_slots.length
    @available_slots.each_with_index do |time,i|
      @available_slots_arrays.push([time,@available_slots[i+1]]) if i != length - 1
    end

    if availablity.unavailable_start_time && availablity.unavailable_end_time
      (availablity.unavailable_start_time.round_off(15).to_datetime.to_i .. availablity.unavailable_end_time.round_off(15).to_datetime.to_i).step(60.minutes).each do |time|
        @unavailable_slots.push(Time.zone.at(time).rfc2822)
      end
     length2 = @unavailable_slots.length
      @unavailable_slots.each_with_index do |time,i|
        @unavailable_slots_arrays.push([time,@unavailable_slots[i+1]]) if i != length2 - 1
      end
    end

    slots = @available_slots_arrays - @unavailable_slots_arrays
    slots.each{|slot_ary| slot_ary.map!{|slot| self.available_date.to_s + ' ' + slot.to_datetime.to_s(:time)}}
    slots.each do |slot|
      slot_t = self.available_slots.build(start_time: slot[0], end_time: slot[1], therapist_id: self.availablity.therapist_id, availablity_id:  self.availablity_id)
      slot_t.save!
    end
  end
end
