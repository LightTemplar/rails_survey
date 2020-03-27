# frozen_string_literal: true

class AddWeightedScoreSumToScores < ActiveRecord::Migration[5.1]
  def change
    add_column :survey_scores, :score_data, :text
  end
end
