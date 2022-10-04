class AddCompletionRateToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :completion_rate, :decimal
  end
end
