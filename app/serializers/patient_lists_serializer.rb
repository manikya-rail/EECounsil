class PatientListsSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :gender, :hourly_rate, :therapist_id, :client_consent_forms
  attr_accessor :default_rate

  def hourly_rate
    object.therapist_rate_per_clients.first.default_rate if object.therapist_rate_per_clients.present?
  end

  def client_consent_forms
    consent_form_ids = ClientConsentForm.where(patient_id: object.id, therapist_id: object.therapist_id).pluck(:consent_form_id)
    return ConsentForm.find(consent_form_ids).pluck(:id, :name) if consent_form_ids
  end
end


