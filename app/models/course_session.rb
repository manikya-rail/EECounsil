class CourseSession < ApplicationRecord
  belongs_to :course
  has_many :media, class_name: 'Medium', dependent: :destroy, as: :mediable
  accepts_nested_attributes_for :media, reject_if: :all_blank
  validates :media, presence: true
end
