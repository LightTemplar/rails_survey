class AddCompleteSurveyToOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :options, :complete_survey, :boolean
  end
end
