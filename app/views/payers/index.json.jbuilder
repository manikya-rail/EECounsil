json.set! :data do
  json.array! @payers do |payer|
    json.partial! 'payers/payer', payer: payer
    json.url  "
              #{link_to 'Show', payer }
              #{link_to 'Edit', edit_payer_path(payer)}
              #{link_to 'Destroy', payer, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end
