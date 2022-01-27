class PromoCodeDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "PromoCode.id" },
      code: { source: "PromoCode.code", cond: :like, searchable: true, orderable: true },
      promo_value:  { source: "PromoCode.promo_value",  cond: :like },
      promo_type:      { source: "PromoCode.promo_type" },
      duration_in_months:  { source: "PromoCode.duration_in_months" },
    }
  end

  def data
    records.map do |record|
      {
       id:         record.id,
       promo_type: record.promo_type,
       promo_value:  record.promo_value,
       code:      record.code,
       duration_in_months: record.duration_in_months,
      }
    end
  end

  def get_raw_records
    PromoCode.all
  end
end
