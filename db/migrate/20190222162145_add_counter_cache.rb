# frozen_string_literal: true

class AddCounterCache < ActiveRecord::Migration
  def change
    add_column :displays, :instrument_questions_count, :integer
  end
end
