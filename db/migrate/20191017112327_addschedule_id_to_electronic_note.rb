class AddscheduleIdToElectronicNote < ActiveRecord::Migration[5.2]
  def change
  	add_column :electronic_notes, :schedule_id,:integer 
  end
end
