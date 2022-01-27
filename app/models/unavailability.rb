class Unavailability < ApplicationRecord
  belongs_to :available_day
  validates :unavailable_start_time, :unavailable_end_time, presence: true
end
