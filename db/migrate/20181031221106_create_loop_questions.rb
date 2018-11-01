class CreateLoopQuestions < ActiveRecord::Migration
  def change
    create_table :loop_questions do |t|
      t.integer :instrument_question_id
      t.string :parent
      t.string :looped
      t.timestamps null: false
      t.datetime :deleted_at
    end
  end
end
