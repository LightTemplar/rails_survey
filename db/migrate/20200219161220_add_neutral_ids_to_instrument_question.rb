# frozen_string_literal: true

class AddNeutralIdsToInstrumentQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :multiple_skips, :value_operator, :string
    rename_column :instrument_questions, :skip_operation, :next_question_operator
    add_column :instrument_questions, :multiple_skip_operator, :string
    add_column :instrument_questions, :next_question_neutral_ids, :text
    add_column :instrument_questions, :multiple_skip_neutral_ids, :text
  end
end
