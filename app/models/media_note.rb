class MediaNote < ApplicationRecord
  mount_uploader :item, MediaUploader

  belongs_to :patient
  belongs_to :therapist
  after_commit :broadcast

  def broadcast
    ActionCable.server.broadcast "notifications:#{self.recipient_id}", as_json.merge(action: 'medianoteaction' )
  end


  # validate :check_duration_if_video

  # def check_duration_if_video
  #   if item.content_type.include?('video')
  #     duration = FFMPEG::Movie.new(item.path).duration
  #     if !mediable.sender.has_role? :therapist
  #       if duration > APP_CONFIG['VIDEO_MESSAGE_DURATION']
  #         errors.add(:item, "Video should be less then #{APP_CONFIG['VIDEO_MESSAGE_DURATION']} seconds")
  #       end
  #     else
  #       time_duration = Schedule.find(mediable.schedule_id).patient_package_plan.time_duration_in_hours * 60 * 60
  #       if duration > time_duration
  #          errors.add(:item, "Video should be less then #{time_duration} seconds")
  #       end
  #     end
  #   end
  # end

  def as_json
    {
      id: self.id,
      item: self.attributes['item'],
      url: self.item.url,
      content_type: self.item.content_type,
      recipient_id: self.recipient_id,
      user_id: self.user_id,
      schedule_id: self.schedule_id
    }
  end

end
