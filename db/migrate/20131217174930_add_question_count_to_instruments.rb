class AddQuestionCountToInstruments < ActiveRecord::Migration[4.2]
  def change
    add_column :instruments, :question_count, :integer
  end
end
