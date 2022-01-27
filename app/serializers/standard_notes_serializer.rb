class StandardNotesSerializer < ActiveModel::Serializer
  attributes :id, :summary, :schedule_id, :patient_id, :therapist_id, :draft, :online, :cognitive_functioning,
              :affect, :mood, :interpersonal, :functional_status, :medications, :current_functioning,
              :topics_discussed, :treatment_plan_objective_1, :treatment_plan_objective_2,
              :additional_notes, :plan, :recommendation, :risk_factor_ids, :intervention_ids, :created_time

  def summary
    return object.decrypt_note_summary if object.summary
  end

  def risk_factor_ids
    ActiveModel::ArraySerializer.new(RiskFactor.where(id: object.risk_factor_ids.split(',')), each_serializer: RiskFactorSerializer) if object.risk_factor_ids
  end

  def intervention_ids
    ActiveModel::ArraySerializer.new(Intervention.where(id: object.intervention_ids.split(',')), each_serializer: InterventionSerializer) if object.intervention_ids
  end

  def created_time
    object.created_at
  end

end
