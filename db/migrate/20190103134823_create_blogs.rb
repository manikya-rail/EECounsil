class CreateBlogs < ActiveRecord::Migration[5.2]
  def change
    create_table :blogs do |t|
      t.references :category, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
