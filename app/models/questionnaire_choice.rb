class QuestionnaireChoice < ApplicationRecord
	belongs_to :questionnaire

	validates :option, presence: true 
end
