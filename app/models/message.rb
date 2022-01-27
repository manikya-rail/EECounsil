class Message < ApplicationRecord

	belongs_to :schedule, optional: true
	has_many :media, class_name: 'Medium', dependent: :destroy, as: :mediable
	accepts_nested_attributes_for :media, reject_if: :all_blank

	# validates :sender_id, :receiver_id, presence: true
	validate :only_one_thing_should_be_selected
	after_create_commit :broadcast
	validate :check_plan, if: -> { self.media.present? }


	def sender
		User.find(sender_id)
	end

	def receiver
		User.find(receiver_id)
	end

	private

	def check_plan
		# if self.schedule.patient_package_plan.plan_type == 'text'
			# errors.add(:item, "You can't upload the videos on the text plan")
		# end
	end

	def broadcast
		sender = User.find(self.sender_id)
		receiver = User.find(self.receiver_id)
		UserMailer.send_message_notification(sender, receiver).deliver!
		media_atr = self.media.present? ? self.media.first.item : ''
		media_attribute = []
		media_attribute = self.media.present? ? [{ item: media_atr.filename, url: media_atr.url, content_type: media_atr.content_type }] : []
  	ActionCable.server.broadcast "notifications:#{self.receiver_id}", as_json.merge(action: 'messageaction', media: media_attribute,caller: self.sender_id )

		# ActionCable.server.broadcast "chat_channel_room_#{self.schedule_id}", as_json.merge(action: 'testaction', media: media_attribute)
	end

	def only_one_thing_should_be_selected
		if media.present? && message_content.present?
			errors.add(:message, 'You can send only one thing at a time')
		end
	end
end
