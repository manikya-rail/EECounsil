class CategoryDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
       id: { source: "Category.id", cond: :eq },
       name: { source: "Category.name", cond: :like, searchable: true, orderable: true },
    }
  end

  def data
    records.map do |record|
      {
        id:        record.id,
        name:      record.name,
      }
    end
  end

  def get_raw_records
    Category.all
  end

end