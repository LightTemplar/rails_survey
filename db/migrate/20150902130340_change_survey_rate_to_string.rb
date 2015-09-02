class ChangeSurveyRateToString < ActiveRecord::Migration
  def change
    change_column :surveys, :completion_rate, :string
  end
end
