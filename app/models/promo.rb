class Promo < ApplicationRecord
  belongs_to :therapist
  belongs_to :promo_code
end
