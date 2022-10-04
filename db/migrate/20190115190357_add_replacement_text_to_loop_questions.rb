class AddReplacementTextToLoopQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :loop_questions, :replacement_text, :text
  end
end
