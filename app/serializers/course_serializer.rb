class CourseSerializer < ActiveModel::Serializer
  attributes :id, :price ,:description, :name, :media
  def media
   	if object.media.present?
  		{ url: object.media.first.item.url }
  	end
  end
end
