json.set! :data do
  json.array! @payment_plans do |payment_plan|
    json.partial! 'payment_plans/payment_plan', payment_plan: payment_plan
    json.url  "
              #{link_to 'Show', payment_plan }
              #{link_to 'Edit', edit_payment_plan_path(payment_plan)}
              #{link_to 'Destroy', payment_plan, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end