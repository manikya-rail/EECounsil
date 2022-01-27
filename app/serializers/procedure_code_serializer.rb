class ProcedureCodeSerializer < ActiveModel::Serializer
  attributes :id, :code, :description, :duration

  def duration
    return object.duration.to_s + 'minutes' if object.duration.present?
  end
end
