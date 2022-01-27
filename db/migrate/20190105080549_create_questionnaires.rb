class CreateQuestionnaires < ActiveRecord::Migration[5.2]
  def change
    create_table :questionnaires do |t|
      t.integer :question_type
      t.text :question

      t.timestamps
    end
  end
end
