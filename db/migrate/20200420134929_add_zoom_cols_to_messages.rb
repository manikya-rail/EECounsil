class AddZoomColsToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :meeting_id, :string
    add_column :messages, :join_url, :string
    add_column :messages, :host_id, :string
  end
end
