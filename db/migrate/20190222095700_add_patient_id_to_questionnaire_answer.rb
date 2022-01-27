class AddPatientIdToQuestionnaireAnswer < ActiveRecord::Migration[5.2]
  def change
    add_column :questionnaire_answers, :patient_id, :integer
    remove_column :questionnaire_answers, :questionnaire_choice_ids, :text
  end
end
