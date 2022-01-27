class UserPaymentMode < ApplicationRecord
  enum payment_mode: [:stripe]
  belongs_to :user
end
