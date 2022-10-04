class AddSurveyAggregatorToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :survey_aggregator, :string
    add_column :option_scores, :next_question, :boolean
  end
end
