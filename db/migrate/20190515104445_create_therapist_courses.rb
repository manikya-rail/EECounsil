class CreateTherapistCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :therapist_courses do |t|
    	  t.integer :course_id
    	  t.integer :therapist_id
      t.timestamps
    end
  end
end