json.set! :data do
  json.array! @service_codes do |service_code|
    json.partial! 'service_codes/service_code', service_code: service_code
    json.url  "
              #{link_to 'Show', service_code }
              #{link_to 'Edit', edit_procedure_code_path(service_code)}
              #{link_to 'Destroy', service_code, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end
