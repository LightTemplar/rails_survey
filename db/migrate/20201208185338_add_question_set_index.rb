class AddQuestionSetIndex < ActiveRecord::Migration
  def change
    add_index :question_sets, :title unless index_exists?(:question_sets, :title)
    add_index :instructions, :title unless index_exists?(:instructions, :title)
  end
end
