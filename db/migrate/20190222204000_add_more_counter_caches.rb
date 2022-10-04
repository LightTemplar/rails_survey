# frozen_string_literal: true

class AddMoreCounterCaches < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :versions_count, :integer, default: 0
    add_column :questions, :images_count, :integer, default: 0
    add_column :instrument_questions, :loop_questions_count, :integer, default: 0
    add_column :option_sets, :option_in_option_sets_count, :integer, default: 0

    Question.reset_column_information
    Question.all.each do |q|
      q.update_versions_cache
      Question.reset_counters(q.id, :images)
    end

    InstrumentQuestion.reset_column_information
    InstrumentQuestion.all.each do |iq|
      InstrumentQuestion.reset_counters(iq.id, :loop_questions)
    end

    Display.reset_column_information
    Display.all.each do |d|
      Display.reset_counters(d.id, :instrument_questions)
    end

    OptionSet.reset_column_information
    OptionSet.all.each do |os|
      OptionSet.reset_counters(os.id, :option_in_option_sets)
    end
  end
end
