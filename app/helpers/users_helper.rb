module UsersHelper
  def skill(schedule)
    current_therapist_Skills = schedule.therapist.therapist_skills
    Therapist.all.map{ |y| y  if ((y.therapist_skills & current_therapist_Skills).present? && y.id != schedule.therapist_id && y.deleted_at == nil && y.status == true) }.compact || Therapist.where.not(id: schedule.therapist_id).where(deleted_at: nil, status: true)

   #  Therapist.where(therapist_skills: current_therapist_Skills).where.not(id: schedule.therapist_id) || Therapist.where.not(id: schedule.therapist_id)
  end
end
