class DropTableInstrumentQuestionSet < ActiveRecord::Migration[4.2]
  def change
    drop_table :instrument_question_sets
  end
end
