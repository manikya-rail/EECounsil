class InterventionDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "Intervention.id" },
      title: { source: "Intervention.title", cond: :like, searchable: true, orderable: true },
    }
  end

  def data
    interventions = []
    records.each do |record|
      interventions << {id: record.id, title: record.title}
    end
    interventions
  end

  def get_raw_records
    Intervention.all
  end
end
