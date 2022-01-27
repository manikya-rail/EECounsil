json.set! :data do
  json.array! @consent_forms do |consent_form|
    json.partial! 'consent_forms/consent_form', consent_form: consent_form
    json.url  "
              #{link_to 'Show', consent_form }
              #{link_to 'Edit', edit_consent_form_path(consent_form)}
              #{link_to 'Destroy', consent_form, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end
