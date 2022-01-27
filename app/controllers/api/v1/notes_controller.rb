module Api
  module V1
    class NotesController < ApplicationController
      def fetch_diagnosis_codes
        render json: {diagnosis_codes: ActiveModel::ArraySerializer.new(DiagnosisCode.all, each_serializer: DiagnosisCodeSerializer)}
      end

      def create_diagnosis_code
        diagnosis_code = DiagnosisCode.create!(code: params[:code], description: params[:description])
        render json: {message: 'success', diagnosis_code: diagnosis_code}
      end

      def fetch_risk_factors
        render json: {risk_factors: ActiveModel::ArraySerializer.new(RiskFactor.all, each_serializer: RiskFactorSerializer)}
      end

      def fetch_interventions
        render json: {interventions: ActiveModel::ArraySerializer.new(Intervention.all, each_serializer: InterventionSerializer)}
      end

      def fetch_all_notes
        schedules = Schedule.where(patient_id: params[:patient_id], therapist_id: params[:therapist_id]).order("created_at asc")
        diagnosis_treatment_notes = DiagnosisTreatmentNote.where(therapist_id: params[:therapist_id], patient_id: params[:patient_id])
        render json: {appointments: ActiveModel::ArraySerializer.new(schedules, each_serializer: SchedulesSerializer),
                      current_date: Time.now.utc, diagnosis_treatment_notes: ActiveModel::ArraySerializer.new(diagnosis_treatment_notes, each_serializer: DiagnosisNotesSerializer)}
      end

      def attach_files_for_notes
        params_hsh = params[:note_files]
        @media_note = MediaNote.new(item: params_hsh[:item], patient_id: params_hsh[:patient_id], therapist_id: params_hsh[:therapist_id], user_id: params_hsh[:therapist_id],
                                    recipient_id: params_hsh[:patient_id], schedule_id: params_hsh[:schedule_id], action: "mediafilenotes")
        if @media_note.save
          schedule = @media_note.schedule_id ? Schedule.where(id: @media_note.schedule_id) : []
          render json: { appointments: ActiveModel::ArraySerializer.new(schedule, each_serializer: SchedulesSerializer), media_notes: @media_note.as_json, status: 200}
        else
          render json: { media_notes: @media_note.errors, status: 500 }
        end
      end

      def fetch_file_for_note
        media_notes = MediaNote.where(patient_id: params_hsh[:patient_id], therapist_id: params_hsh[:therapist_id], schedule_id: params_hsh[:schedule_id])
        render json: { media_notes: media_notes.as_json}
      end

      def delete_file_note
        media_note = MediaNote.find(params[:id])
         if media_note.destroy
          schedule = media_note.schedule_id ? Schedule.where(id: media_note.schedule_id) : []
          render json: {message: 'File deleted successfully', appointments: ActiveModel::ArraySerializer.new(schedule, each_serializer: SchedulesSerializer)}
        else
          render json: media_note.errors
        end
      end

      def fetch_draft_notes
        simple_note_draft = SimpleNote.where(therapist_id: params[:therapist_id], patient_id: params[:patient_id], draft: true)
        drafts = [type: 'simple_notes', simple_notes: ActiveModel::ArraySerializer.new(simple_note_draft, each_serializer: SimpleNotesSerializer)]
        standard_note_draft = StandardNote.where(therapist_id: params[:therapist_id], patient_id: params[:patient_id], draft: true)
        drafts << [type: 'standard_notes', standard_notes: ActiveModel::ArraySerializer.new(standard_note_draft, each_serializer: StandardNotesSerializer)]
        media_notes = MediaNote.where(patient_id: params[:patient_id], therapist_id: params[:therapist_id], action: "mediafilenotes")
        render json: {drafts: drafts.flatten, media_notes: media_notes.as_json}
      end
    end
  end
end
