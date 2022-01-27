class UserMedium < ApplicationRecord
  mount_uploader :item, MediaUploader
  belongs_to :user, optional: true

  enum media_type: {profile_picture: 0, introduction_video: 1}


  validate :profile_picture , if: -> { media_type == 'profile_picture'}
  validate :introduction_video , if: -> { media_type == 'introduction_video'}

  def profile_picture
    if item.present?
      success = item.content_type.to_str.include?('image')
      errors.add(:item, 'File format is not valid') if !success
    end
  end

  def introduction_video
    if item.present?
      success = item.content_type.to_str.include?('video')
      errors.add(:item, 'File format is not valid') if !success
    end
  end
end
