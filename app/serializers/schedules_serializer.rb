class SchedulesSerializer < ActiveModel::Serializer
  attributes :id ,:therapist_id, :patient_id, :starts_at, :ends_at, :schedule_starts_at, :schedule_ends_at, :status, :created_time, :updated_time, :schedule_date,
              :patient_package_plan_id, :therapist_fees, :admin_fees, :paid_to_therapist, :scheduled_by, :procedure_code_id, :notes, :files

  def created_time
    object.created_at
  end

  def updated_time
    object.updated_at
  end

  def schedule_starts_at
    object.starts_at if object.starts_at
  end

  def schedule_ends_at
    object.ends_at if object.ends_at
  end

  def procedure_code_id
    procedure_codes = ProcedureCode.where(id: object.procedure_code_id) if object.procedure_code_id
    ActiveModel::ArraySerializer.new(procedure_codes, each_serializer: ProcedureCodeSerializer) if procedure_codes
  end

  def notes
    simple_note = SimpleNote.find_by(schedule_id: object.id, therapist_id: object.therapist_id, patient_id: object.patient_id)
    return [type: 'simple', content: SimpleNotesSerializer.new(simple_note).serializable_hash] if simple_note.present?
    standard_note = StandardNote.find_by(schedule_id: object.id, therapist_id: object.therapist_id, patient_id: object.patient_id)
    return [type: 'standard', content: StandardNotesSerializer.new(standard_note).serializable_hash] if standard_note.present?
  end

  def files
    return MediaNote.where(patient_id: object.patient_id, therapist_id: object.therapist_id, schedule_id: object.id, action: "mediafilenotes")
  end

end
