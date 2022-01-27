class Address < ApplicationRecord
  belongs_to :user
  # validates :street_address, :country, presence: true
  # before_save :add_timezone
	# after_validation :replace_error_msg

	def replace_error_msg
		errors.add(:errors, "not valid!") if latitude.blank? || longitude.blank?
	end

	def add_timezone
		self.timezone = Timezone.lookup(self.latitude, self.longitude).name
	end
end
