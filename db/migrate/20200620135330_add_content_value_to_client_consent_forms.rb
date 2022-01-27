class AddContentValueToClientConsentForms < ActiveRecord::Migration[5.2]
  def change
    add_column :client_consent_forms, :content_values, :text
  end
end
