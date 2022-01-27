module Api
  module V1
    class Notes::SimpleNotesController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!
      before_action :find_simple_note, only: [:update, :destroy]

      def index
        simple_notes = SimpleNote.where(therapist_id: params[:therapist_id], patient_id: params[:patient_id])
        render json: {simple_notes: ActiveModel::ArraySerializer.new(simple_notes, each_serializer: SimpleNotesSerializer)}
      end

      def create
        note = SimpleNote.new(get_simple_note_params)
        if note.save!
          schedule = note.schedule_id ? Schedule.where(id: note.schedule_id) : []
          render json: {message: 'Simple Note created successfully', simple_note_id: note.id, appointments: ActiveModel::ArraySerializer.new(schedule, each_serializer: SchedulesSerializer)}
        else
          render json: note.errors
        end
      end

      def update
        if @simple_note.update(get_simple_note_params)
          schedule = @simple_note.schedule_id ? Schedule.where(id: @simple_note.schedule_id) : []
          render json: {message: 'Simple Note updated successfully', appointments: ActiveModel::ArraySerializer.new(schedule, each_serializer: SchedulesSerializer)}
        else
          render json: @simple_note.errors
        end
      end

      def destroy
        if @simple_note.destroy
          schedule = Schedule.where(id: @simple_note.schedule_id) if @simple_note.schedule_id
          appointments = schedule ? ActiveModel::ArraySerializer.new(schedule, each_serializer: SchedulesSerializer) : []
          render json: {message: 'Simple Note deleted successfully', appointments: appointments}
        else
          render json: @simple_note.errors
        end
      end

      private

      def find_simple_note
        @simple_note = SimpleNote.find(params[:id])
      end

      def get_simple_note_params
        params.require(:simple_note).permit(:content, :schedule_id, :patient_id, :therapist_id, :draft, :online)
      end
    end
  end
end
