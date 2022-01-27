class RiskFactorDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "RiskFactor.id" },
      title: { source: "RiskFactor.title", cond: :like, searchable: true, orderable: true },
    }
  end

  def data
    risk_factors = []
    records.each do |record|
      risk_factors << {id: record.id, title: record.title}
    end
    risk_factors
  end

  def get_raw_records
    RiskFactor.all
  end
end
