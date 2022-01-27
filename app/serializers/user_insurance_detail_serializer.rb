class UserInsuranceDetailSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :npi, :tax_id, :ssn, :member_id, :group_number, :policy_number
end
