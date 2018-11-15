class AddIndexToInstrumentQuestions < ActiveRecord::Migration
  def change
    add_index(:instrument_questions, :identifier)
    add_index(:instrument_questions, :question_id)
  end
end
