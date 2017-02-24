class AddSurveyAggregatorToProject < ActiveRecord::Migration
  def change
    add_column :projects, :survey_aggregator, :string
    add_column :option_scores, :next_question, :boolean
  end
end
