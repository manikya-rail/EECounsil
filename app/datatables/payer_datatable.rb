class PayerDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "Payer.id" },
      payer_id:         { source: "Payer.payer_id" },
      payer_name: { source: "Payer.payer_name", cond: :like, searchable: true, orderable: true },
    }
  end

  def data
    payers = []
    records.each do |record|
      payers << {id: record.id,payer_id: record.payer_id, payer_name: record.payer_name}
    end
    payers
  end

  def get_raw_records
    Payer.all
  end
end
