class AddInstrumentQuestionIdToDisplayInstruction < ActiveRecord::Migration[4.2]
  def change
    add_column :display_instructions, :instrument_question_id, :integer
  end
end
