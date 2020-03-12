# frozen_string_literal: true

class AddBasePointScoreToScoreUnit < ActiveRecord::Migration[5.1]
  def change
    add_column :score_units, :base_point_score, :float
  end
end
