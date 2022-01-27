class ChangeTypeOfFeildInQuestionnaireAnswer < ActiveRecord::Migration[5.2]
  def change
    add_column :questionnaire_answers, :questionnaire_choice_id, :integer
  end
end
