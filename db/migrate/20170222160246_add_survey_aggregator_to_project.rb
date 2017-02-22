class AddSurveyAggregatorToProject < ActiveRecord::Migration
  def change
    add_column :projects, :survey_aggregator, :string
  end
end
