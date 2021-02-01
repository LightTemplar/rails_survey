# frozen_string_literal: true

class AddScoreSchemeIdToRedFlag < ActiveRecord::Migration[5.1]
  def change
    add_column :red_flags, :score_scheme_id, :integer
    add_index :red_flags, :score_scheme_id
  end
end
