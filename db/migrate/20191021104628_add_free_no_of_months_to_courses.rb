class AddFreeNoOfMonthsToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :free_months, :integer
    add_column :therapist_courses, :trail_date, :datetime
    add_column :therapist_courses, :purchased, :boolean, default: false
  end
end
