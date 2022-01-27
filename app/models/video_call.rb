class VideoCall < Message
	after_create_commit :broadcast
	has_many :electronic_notes

	private
	def sender
		User.find(sender_id)
	end

	def broadcast
		ActionCable.server.broadcast "notifications:#{self.receiver_id}", as_json.merge(action: 'videoaction', media: [],caller: sender, meeting_id: self.meeting_id, join_url: self.join_url, host_id: self.host_id )
	end
end
