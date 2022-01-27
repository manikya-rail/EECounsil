class TherapistDatatable < AjaxDatatablesRails::ActiveRecord

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id: { source: "Therapist.id", cond: :eq },
      name: { source: "Therapist.first_name", cond: :like, searchable: true, orderable: true },
      amount: { source: "Schedule.therapist_fees", cond: :like, orderable: true },
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        amount: record.schedules.where(status: "completed", paid_to_therapist: false).pluck(:therapist_fees).sum,
        name: record.first_name + ' ' +record.last_name ,
      }
    end
  end

  def get_raw_records
    Therapist.includes(:schedules).where(schedules: {status: 'completed', paid_to_therapist: false})
  end
end