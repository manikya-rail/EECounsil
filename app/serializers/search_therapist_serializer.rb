class SearchTherapistSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :therapist_skills, :profile_picture, :introduction_video, :therapist_type
end
