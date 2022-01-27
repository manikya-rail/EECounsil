json.extract! promo_code, :id, :promo_type, :promo_value, :code, :duration_in_months, :created_at, :updated_at
json.url promo_code_url(promo_code, format: :json)
