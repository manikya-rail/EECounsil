class CreateSocialProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :social_profiles do |t|
      t.integer :user_id
      t.integer :social_profile_type
      t.string :link
      t.timestamps
    end
  end
end