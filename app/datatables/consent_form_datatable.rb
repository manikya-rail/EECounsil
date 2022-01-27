class ConsentFormDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "ConsentForm.id" },
      name: { source: "ConsentForm.name", cond: :like, searchable: true, orderable: true },
      content:  { source: "ConsentForm.content",  cond: :like },
    }
  end

  def data
    consent_forms = []
    records.each do |record|
      consent_forms << {id: record.id, name: record.name, content: record.content}
    end
    consent_forms
  end

  def get_raw_records
    ConsentForm.all
  end
end
