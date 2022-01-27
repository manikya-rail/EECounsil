class DocumentSerializer < ActiveModel::Serializer
  attributes :id, :media, :content_type, :sent_from, :sent_to, :date

  def media
    object.item.url
  end

  def content_type
    object.item.content_type
  end

  def sent_from
    User.find(object.user_id).full_name
  end

  def sent_to
    User.find(object.recipient_id).full_name
  end

  def date
    object.created_at.strftime('%d %b %Y')
  end
end
