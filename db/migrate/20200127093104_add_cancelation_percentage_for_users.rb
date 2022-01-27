class AddCancelationPercentageForUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :cancel_percentage, :string
  end
end
