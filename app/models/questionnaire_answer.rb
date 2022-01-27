class QuestionnaireAnswer < ApplicationRecord
	belongs_to :questionnaire
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'
end
