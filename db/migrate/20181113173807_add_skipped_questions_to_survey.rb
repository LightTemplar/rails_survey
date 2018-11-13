class AddSkippedQuestionsToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :skipped_questions, :text
  end
end
