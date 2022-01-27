class PatientPackagesSerializer < ActiveModel::Serializer
  attributes :id, :patient_id ,:package_id, :expiry_date, :patient_package_plans
end
