class CreateTherapistRatePerClients < ActiveRecord::Migration[5.2]
  def change
    create_table :therapist_rate_per_clients do |t|
    	t.integer :therapist_id
    	t.string :email, null: false, index: { unique: true }
      t.integer :patient_id
      t.integer :default_rate
      t.timestamps
    end
  end
end
