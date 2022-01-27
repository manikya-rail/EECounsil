json.set! :data do
  json.array! @promo_codes do |promo_code|
    json.partial! 'promo_codes/promo_code', promo_code: promo_code
    json.url  "
              #{link_to 'Show', promo_code }
              #{link_to 'Edit', edit_promo_code_path(promo_code)}
              #{link_to 'Destroy', promo_code, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end