class ChangeSurveyRateToString < ActiveRecord::Migration[4.2]
  def change
    change_column :surveys, :completion_rate, :string
  end
end
