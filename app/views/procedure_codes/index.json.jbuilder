json.set! :data do
  json.array! @procedure_codes do |procedure_code|
    json.partial! 'procedure_codes/procedure_code', procedure_code: procedure_code
    json.url  "
              #{link_to 'Show', procedure_code }
              #{link_to 'Edit', edit_procedure_code_path(procedure_code)}
              #{link_to 'Destroy', procedure_code, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end
