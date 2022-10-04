# frozen_string_literal: true

class AddCounterCache < ActiveRecord::Migration[4.2]
  def change
    add_column :displays, :instrument_questions_count, :integer
  end
end
