class AddCompleteSurveyToOptions < ActiveRecord::Migration
  def change
    add_column :options, :complete_survey, :boolean
  end
end
