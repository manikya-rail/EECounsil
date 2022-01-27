class CreateCourseSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :course_sessions do |t|
      t.integer :course_id
      t.timestamps
    end
  end
end
