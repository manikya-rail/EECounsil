class AddSkillToQuestionnaireChoices < ActiveRecord::Migration[5.2]
  def change
  	add_column :questionnaire_choices, :skill, :text
  end
end
