class ChangeQuestionInstructionsDefaultValueToBlankString < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:questions, :instructions, '')
  end
end
