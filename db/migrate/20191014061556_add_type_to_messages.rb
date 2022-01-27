class AddTypeToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :type, :string
  end
end
