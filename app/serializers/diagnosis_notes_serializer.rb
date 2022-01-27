class DiagnosisNotesSerializer < ActiveModel::Serializer
  attributes :id, :diagnosis_date, :diagnosis_time, :presenting_problem, :goal, :objective,
             :treatment_frequency, :assigned_treatment_date, :assigned_treatment_time, :schedule_id, :patient_id,
             :therapist_id, :treatment_notes_added, :diagnosis_code_ids, :created_time

  def diagnosis_code_ids
    ActiveModel::ArraySerializer.new(DiagnosisCode.where(id: object.diagnosis_code_ids.split(',')), each_serializer: DiagnosisCodeSerializer) if object.diagnosis_code_ids
  end

  def created_time
    object.created_at
  end

end
