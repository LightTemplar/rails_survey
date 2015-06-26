class RenameSurveyScoreId < ActiveRecord::Migration
  def change
    rename_column :unit_scores, :score_id, :survey_score_id
  end
end
