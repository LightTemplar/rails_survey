# frozen_string_literal: true

class AddIndexToInstrumentQuestion < ActiveRecord::Migration[5.1]
  def change
    add_index :instrument_questions, :instrument_id
    add_index :instrument_questions, :display_id
    add_index :responses, :question_id
  end
end
