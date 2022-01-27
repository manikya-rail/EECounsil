class SimpleNotesSerializer < ActiveModel::Serializer
  attributes :id, :content, :schedule_id, :patient_id, :therapist_id, :draft, :online, :created_time

  def content
    return object.decrypt_note_content if object.content
  end

  def created_time
    object.created_at
  end

end
