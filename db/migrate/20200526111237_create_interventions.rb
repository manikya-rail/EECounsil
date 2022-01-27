class CreateInterventions < ActiveRecord::Migration[5.2]
  def change
    create_table :interventions do |t|
      t.string :title
      t.timestamps
    end

    interventions_ary = ['Cognitive Challenging', 'Cognitive Refocusing', 'Cognitive Reframing',
                         'Communication Skills', 'DBT', 'Exploration of Coping Patterns',
                          'Exploration of Emotions', 'Exploration of Relationship Patterns',
                          'Guided Imagery', 'Interactive Feedback', 'Interpersonal Resolutions',
                          'Mindfulness Training', 'Preventative Services', 'Other']
    interventions_ary.each do |intervention|
      Intervention.create(title: intervention)
    end
  end
end
