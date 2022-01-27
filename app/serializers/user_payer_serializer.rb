class UserPayerSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :payer


  def payer
    Payer.find(object.payer_id)
  end

end