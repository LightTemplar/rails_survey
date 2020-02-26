# frozen_string_literal: true

class RodoConditionSkips < ActiveRecord::Migration[5.1]
  def change
    remove_column :condition_skips, :condition_question_identifier, :string
    remove_column :condition_skips, :condition_option_identifier, :string
    remove_column :condition_skips, :option_identifier, :string
    remove_column :condition_skips, :condition, :string
    add_column :condition_skips, :question_identifiers, :text
    add_column :condition_skips, :option_ids, :text
    add_column :condition_skips, :values, :text
    add_column :condition_skips, :value_operators, :text
  end
end
