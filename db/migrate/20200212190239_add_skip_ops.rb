# frozen_string_literal: true

class AddSkipOps < ActiveRecord::Migration[5.1]
  def change
    add_column :instrument_questions, :skip_operation, :string
    add_column :option_in_option_sets, :exclusion_ids, :text
    add_column :next_questions, :value_operator, :string
    remove_column :option_in_option_sets, :is_exclusive, :boolean
  end
end
