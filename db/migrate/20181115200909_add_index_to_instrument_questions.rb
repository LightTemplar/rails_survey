class AddIndexToInstrumentQuestions < ActiveRecord::Migration[4.2]
  def change
    add_index(:instrument_questions, :identifier)
    add_index(:instrument_questions, :question_id)
  end
end
