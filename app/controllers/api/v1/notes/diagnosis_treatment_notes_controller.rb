module Api
  module V1
    class Notes::DiagnosisTreatmentNotesController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!
      before_action :find_diagnosis_treatment_note, only: [:update, :destroy]

      def index
        diagnosis_treatment_notes = DiagnosisTreatmentNote.where(therapist_id: params[:therapist_id], patient_id: params[:patient_id])
        render json: {diagnosis_treatment_notes: ActiveModel::ArraySerializer.new(diagnosis_treatment_notes, each_serializer: DiagnosisNotesSerializer)}
      end

      def create
        note = DiagnosisTreatmentNote.new(get_diagnosis_treatment_note_params)
        if note.save!
          render json: {message: 'Diagnosis Treatment Note created successfully', diagnosis_note: ActiveModel::ArraySerializer.new([note], each_serializer: DiagnosisNotesSerializer)}
        else
          render json: note.errors
        end
      end

      def update
        if @diagnosis_treatment_note.update(get_diagnosis_treatment_note_params)
          render json: {message: 'Diagnosis Treatment Note updated successfully', diagnosis_note: ActiveModel::ArraySerializer.new([@diagnosis_treatment_note], each_serializer: DiagnosisNotesSerializer)}
        else
          render json: @diagnosis_treatment_note.errors
        end
      end

      def destroy
        if @diagnosis_treatment_note.destroy
          render json: {message: 'Diagnosis Treatment Note deleted successfully', diagnosis_note: ActiveModel::ArraySerializer.new([@diagnosis_treatment_note], each_serializer: DiagnosisNotesSerializer)}
        else
          render json: @diagnosis_treatment_note.errors
        end
      end

      private

      def find_diagnosis_treatment_note
        @diagnosis_treatment_note = DiagnosisTreatmentNote.find(params[:id])
      end

      def get_diagnosis_treatment_note_params
        params.require(:diagnosis_treatment_note).permit(:diagnosis_date, :diagnosis_time, :presenting_problem, :goal, :objective,
                       :treatment_frequency, :assigned_treatment_date, :assigned_treatment_time, :schedule_id, :patient_id,
                       :therapist_id, :treatment_notes_added, :diagnosis_code_ids)
      end
    end
  end
end
