class CreateScoreUnitQuestions < ActiveRecord::Migration
  def change
    create_table :score_unit_questions do |t|
      t.integer :score_unit_id
      t.integer :question_id

      t.timestamps
    end
  end
end
