class RemoveAndAddColumnSkillsInUsersWithArrayType < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :skills, :string
    add_column :users, :therapist_skills, :string, array: true, default: []
  end
end
