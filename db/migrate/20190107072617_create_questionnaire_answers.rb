class CreateQuestionnaireAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :questionnaire_answers do |t|
    	t.integer :questionnaire_id
			t.text  :questionnaire_choice_ids

      t.timestamps
    end
  end
end
