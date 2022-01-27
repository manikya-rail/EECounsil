class CreateQuestionnaireChoices < ActiveRecord::Migration[5.2]
  def change
    create_table :questionnaire_choices do |t|
    	t.text :option
			t.integer :questionnaire_id
			
      t.timestamps
    end
  end
end
