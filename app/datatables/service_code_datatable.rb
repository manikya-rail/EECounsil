class ServiceCodeDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "ServiceCode.id" },
      service_type_code: { source: "ServiceCode.service_type_code", cond: :like, searchable: true, orderable: true },
      description:  { source: "ServiceCode.description",  cond: :like },
    }
  end

  def data
    service_codes = []
    records.each do |record|
      service_codes << {id: record.id, service_type_code: record.service_type_code, description: record.description}
    end
    service_codes
  end

  def get_raw_records
    ServiceCode.all
  end
end
