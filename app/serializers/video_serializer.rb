class VideoSerializer < ActiveModel::Serializer
  attributes :id, :description, :media

  def media
    object.media.item.url
  end
end
