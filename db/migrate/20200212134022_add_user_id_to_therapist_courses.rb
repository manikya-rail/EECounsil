class AddUserIdToTherapistCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :therapist_courses, :user_id, :integer
  end
end
