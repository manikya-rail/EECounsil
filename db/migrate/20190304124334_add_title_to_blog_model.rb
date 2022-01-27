class AddTitleToBlogModel < ActiveRecord::Migration[5.2]
  def change
    add_column :blogs, :title, :string
  end
end
