class Payer < ApplicationRecord
  has_many :user_payers, dependent: :destroy
end
