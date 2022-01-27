class DiagnosisCodeSerializer < ActiveModel::Serializer
  attributes :id, :code, :description
end
