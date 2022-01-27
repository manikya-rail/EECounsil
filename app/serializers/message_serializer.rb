class MessageSerializer < ActiveModel::Serializer
  attributes :sender_id, :receiver_id ,:message_content, :schedule_id, :media, :created_at
end
