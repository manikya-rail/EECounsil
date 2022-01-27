class PlanDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "PaymentPlan.id" },
      name: { source: "PaymentPlan.name", cond: :like, searchable: true, orderable: true },
      # description:  { source: "PaymentPlan.description",  cond: :like },
      features: { source: "Feature.feature_name", orderable: false},
      amount:      { source: "PaymentPlan.amount" },
      currency: { source: "PaymentPlan.currency", orderable: false },
      block: { source: "PaymentPlan.block" },
    }
  end

  def data
    plans = []
    records.each do |record|
      plans << {id: record.id, name: record.name, features: record.plan_features&.map(&:feature_names).join(','), amount: record.amount, currency: record.currency, block: record.block}
    end
    plans
  end

  def get_raw_records
    PaymentPlan.all
  end
end
