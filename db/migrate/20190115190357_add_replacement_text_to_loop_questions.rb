class AddReplacementTextToLoopQuestions < ActiveRecord::Migration
  def change
    add_column :loop_questions, :replacement_text, :text
  end
end
