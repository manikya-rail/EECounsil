class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.string :description
      t.boolean :home_intro_video
      t.timestamps
    end
  end
end
