class ScheduleCharge < ApplicationRecord
  belongs_to :patient
  belongs_to :schedule
  belongs_to :therapist
end
