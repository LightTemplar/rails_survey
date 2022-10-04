class RenameQuestionCountToPreviousQuestionCountInInstruments < ActiveRecord::Migration[4.2]
  def change
    rename_column :instruments, :question_count, :previous_question_count
  end
end
