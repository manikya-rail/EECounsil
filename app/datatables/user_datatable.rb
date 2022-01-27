class UserDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "User.id" },
      first_name: { source: "User.first_name", cond: :like, searchable: true, orderable: true },
      last_name:  { source: "User.last_name",  cond: :like },
      email:      { source: "User.email" },
      birth_date: { source: "User.birth_date", orderable: false },
      gender:     { source: "User.gender"  },
      status:     { source: "User.status" },
      approved:   { source: "User.approved" },
    }
  end

  def data
    records.map do |record|
      {
       id:         record.id,
       first_name: record.first_name,
       last_name:  record.last_name,
       email:      record.email,
       birth_date: record.birth_date,
       gender:     record.gender,
       status:     record.status ? 'Inactive' : 'Active',
       approved:   record.approved,
       DT_RowId:   record.id,
       deleted_at: record.deleted_at,
      }
    end
  end

  def get_raw_records
    params[:role_name] == 'therapist' ? Therapist.all : Patient.all
  end
end
