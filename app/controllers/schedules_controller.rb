class SchedulesController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:status].present?
      @schedules = Schedule.where(status: params[:status]).map{ |d| d if (d.therapist.deleted_at.blank? && d.patient.deleted_at.blank? && d.patient.status == true && d.therapist.status == true) }.compact
    elsif params[:id].present?
      @schedules = Schedule.where('patient_id= :id OR therapist_id= :id', id: params[:id]).map{ |d| d if (d.therapist.deleted_at.blank? && d.patient.deleted_at.blank? && d.patient.status == true && d.therapist.status == true) }.compact
    else
      @schedules = Schedule.all.map{ |d| d if (d.therapist.deleted_at.blank? && d.patient.deleted_at.blank? && d.patient.status == true && d.therapist.status == true) }.compact
    end
  end

  def create
    sch_params = JSON.parse(params[:data_value])
    schedule = Schedule.find(sch_params['sch_id']).dup
    schedule.therapist_id = sch_params['therapist_id']
    schedule.status = 'scheduled'
    patient =  Patient.find(schedule.patient_id)
    if schedule.save
      Schedule.find(sch_params['sch_id']).update(status: 'canceled')
      Schedule.schedule_update(schedule,patient, 'new')
      render json: { success: 'success' }
    else
      render json: { error: schedule.errors }
    end
  end

end