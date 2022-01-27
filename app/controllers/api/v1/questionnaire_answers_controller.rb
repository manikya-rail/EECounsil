module Api
  module V1
    class Api::V1::QuestionnaireAnswersController < ApplicationController

      def create
        @question = QuestionnaireAnswer.find_by(patient_id: get_answer_params[:patient_id], questionnaire_id: get_answer_params[:questionnaire_id] )
        if @question.present?
          @question.update(get_answer_params)
        else
          @question = QuestionnaireAnswer.create!(get_answer_params.merge(patient_id: get_answer_params[:patient_id]))
        end
        render json: @question
      end

      def patient_answers
        @patient = Patient.find(params[:id])
        render json: @patient.questionnaire_answers
      end

      private

      def get_answer_params
        params.require(:questionnaire_answer).permit(:questionnaire_id, :questionnaire_choice_id, :patient_id)
      end

    end
  end
end
