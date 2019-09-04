# frozen_string_literal: true

class RenameColumn < ActiveRecord::Migration
  def change
    rename_column :option_scores, :score_unit_id, :score_unit_question_id
    add_index :options, :identifier
    add_column :score_units, :title, :string
  end
end
