class SocialProfile < ApplicationRecord
  belongs_to :user
  enum social_profile_type: [:facebook, :twitter, :linkedin, :instagram, :gmail]
end
