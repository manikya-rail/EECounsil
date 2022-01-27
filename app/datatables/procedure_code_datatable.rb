class ProcedureCodeDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "ProcedureCode.id" },
      code: { source: "ProcedureCode.code", cond: :like, searchable: true, orderable: true },
      description:  { source: "ProcedureCode.description",  cond: :like },
      duration:      { source: "ProcedureCode.duration" },
    }
  end

  def data
    procedure_codes = []
    records.each do |record|
      procedure_codes << {id: record.id, code: record.code, description: record.description, duration: record.duration}
    end
    procedure_codes
  end

  def get_raw_records
    ProcedureCode.all
  end
end
