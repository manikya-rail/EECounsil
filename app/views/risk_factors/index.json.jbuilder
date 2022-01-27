json.set! :data do
  json.array! @prisk_factors do |prisk_factor|
    json.partial! 'prisk_factors/prisk_factor', prisk_factor: prisk_factor
    json.url  "
              #{link_to 'Show', prisk_factor }
              #{link_to 'Edit', edit_prisk_factor_path(prisk_factor)}
              #{link_to 'Destroy', prisk_factor, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end
