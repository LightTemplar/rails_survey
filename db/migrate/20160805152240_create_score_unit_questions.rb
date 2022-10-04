class CreateScoreUnitQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :score_unit_questions do |t|
      t.integer :score_unit_id
      t.integer :question_id

      t.timestamps
    end
  end
end
