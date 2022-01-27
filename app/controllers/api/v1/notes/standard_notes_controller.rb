module Api
  module V1
    class Notes::StandardNotesController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!
      before_action :find_standard_note, only: [:update, :destroy]

      def index
        standard_notes = StandardNote.where(therapist_id: params[:therapist_id], patient_id: params[:patient_id])
        render json: {standard_notes: ActiveModel::ArraySerializer.new(standard_notes, each_serializer: StandardNotesSerializer)}
      end

      def create
        note = StandardNote.new(get_standard_note_params)
        if note.save!
          schedule = note.schedule_id ? Schedule.where(id: note.schedule_id) : []
          render json: {message: 'Standard Note created successfully', standard_note_id: note.id, appointments: ActiveModel::ArraySerializer.new(schedule, each_serializer: SchedulesSerializer)}
        else
          render json: note.errors
        end
      end

      def update
        if @standard_note.update(get_standard_note_params)
          schedule = @standard_note.schedule_id ? Schedule.where(id: @standard_note.schedule_id) : []
          render json: {message: 'Standard Note updated successfully', appointments: ActiveModel::ArraySerializer.new(schedule, each_serializer: SchedulesSerializer)}
        else
          render json: @standard_note.errors
        end
      end

      def destroy
        if @standard_note.destroy
          schedule = @standard_note.schedule_id ? Schedule.where(id: @standard_note.schedule_id) : []
          render json: {message: 'Standard Note deleted successfully', appointments: ActiveModel::ArraySerializer.new(schedule, each_serializer: SchedulesSerializer)}
        else
          render json: @standard_note.errors
        end
      end

      private

      def find_standard_note
        @standard_note = StandardNote.find(params[:id])
      end

      def get_standard_note_params
        params.require(:standard_note).permit(:summary, :schedule_id, :patient_id, :therapist_id, :draft, :online, :cognitive_functioning,
                                              :affect, :mood, :interpersonal, :functional_status, :medications, :current_functioning,
                                              :topics_discussed, :treatment_plan_objective_1, :treatment_plan_objective_2,
                                              :additional_notes, :plan, :recommendation, :risk_factor_ids, :intervention_ids)
      end
    end
  end
end
