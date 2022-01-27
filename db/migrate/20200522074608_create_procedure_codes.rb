class CreateProcedureCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :procedure_codes do |t|
      t.string :code
      t.string :description
      t.string :duration
      t.timestamps
    end
  end
end
