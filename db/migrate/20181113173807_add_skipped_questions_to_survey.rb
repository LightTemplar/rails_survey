class AddSkippedQuestionsToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :skipped_questions, :text
  end
end
