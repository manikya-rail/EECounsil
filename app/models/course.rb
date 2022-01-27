class Course < ApplicationRecord
  has_many :media, class_name: 'Medium', dependent: :destroy, as: :mediable
  has_many :course_sessions, dependent: :destroy

  accepts_nested_attributes_for :media, :course_sessions, reject_if: :all_blank, allow_destroy: true
  validates :media, :name, :description, :price, presence: true
  validates :course_sessions, presence: true
  validate :check_course, on: :update

  def check_course
    ids = self.course_sessions.map{|m| m.id if m.media.blank? }.compact
    CourseSession.where(id: [ids]).destroy_all
  end

  def as_json(therapist_courses)
      purchase = false
      course = therapist_courses.find_by_course_id(self.id) if therapist_courses.present?
      purchase = course.purchased if course
    {
      id: self.id,
      name: self.name,
      description: self.description,
      price: self.price,
      created_at: self.created_at,
      updated_at: self.updated_at,
      purchase: (purchase ),
      free_months: self.free_months,
      media: self.media.present? ? self.media.first.item.url : nil
    }
  end
end
