json.set! :data do
  json.array! @interventions do |intervention|
    json.partial! 'interventions/intervention', intervention: intervention
    json.url  "
              #{link_to 'Show', intervention }
              #{link_to 'Edit', edit_intervention_path(intervention)}
              #{link_to 'Destroy', intervention, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end
