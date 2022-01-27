class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :payment_plan
end
