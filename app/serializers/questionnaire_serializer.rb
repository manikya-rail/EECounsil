class QuestionnaireSerializer < ActiveModel::Serializer
  attributes :id, :question
  has_many :questionnaire_choices
end
