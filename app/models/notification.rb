class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :schedule
	belongs_to :recipient, class_name: "User"
	belongs_to :notifiable, polymorphic: true
  after_commit :broadcast

  def broadcast
    ActionCable.server.broadcast "notifications:#{self.recipient_id}", as_json.merge(action: 'notificationaction', media: [] )
  end

end
