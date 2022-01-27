json.extract! payment_plan, :id, :name, :description, :amount, :currency, :user_id, :created_at, :updated_at
json.url payment_plan_url(payment_plan, format: :json)
