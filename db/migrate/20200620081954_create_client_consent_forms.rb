class CreateClientConsentForms < ActiveRecord::Migration[5.2]
  def change
    create_table :client_consent_forms do |t|
      t.integer :consent_form_id
      t.integer :therapist_id
      t.integer :patient_id
      t.text :consent_form_content
      t.timestamps
    end
  end
end
