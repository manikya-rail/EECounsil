class BlogSerializer < ActiveModel::Serializer
  attributes :id, :category_id, :title, :description, :media

  def media
    object.media.item.url
  end
end
