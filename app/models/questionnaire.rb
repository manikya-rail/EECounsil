class Questionnaire < ApplicationRecord
	enum type: ["Single Choice", "Multiple Choice"]

	has_many :questionnaire_choices, dependent: :destroy

	validates :question, presence: true
	validates :questionnaire_choices, presence: true

	accepts_nested_attributes_for :questionnaire_choices,
	  reject_if: :all_blank, allow_destroy: true
end
