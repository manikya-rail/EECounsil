class PromoCodeSerializer < ActiveModel::Serializer
  attributes :id, :type, :value, :code
end
