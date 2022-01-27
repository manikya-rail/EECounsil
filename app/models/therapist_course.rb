class TherapistCourse < ApplicationRecord
	belongs_to :therapist
	belongs_to :course

	validates :course_id, presence: true
  validates :therapist_id, presence: true, if: -> {!user_id.present?}
  validates :user_id, presence: true, if: -> {!therapist_id.present?}
 
end
  