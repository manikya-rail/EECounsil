module Api
  module V1
    class QuestionnairesController < ApplicationController
      def index
        @questionnaire = Questionnaire.all.each { |q| QuestionnaireSerializer.new(q) }
        render json: @questionnaire
      end
    end
  end
end
