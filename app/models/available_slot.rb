class AvailableSlot < ApplicationRecord
  belongs_to :available_day
  belongs_to :therapist, class_name: 'User', foreign_key: 'therapist_id'
  belongs_to :availablity
end
