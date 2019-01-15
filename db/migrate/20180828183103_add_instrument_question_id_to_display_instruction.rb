class AddInstrumentQuestionIdToDisplayInstruction < ActiveRecord::Migration
  def change
    add_column :display_instructions, :instrument_question_id, :integer
  end
end
