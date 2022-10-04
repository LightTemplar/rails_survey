class AddIdentifiesSurveyToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :identifies_survey, :boolean, default: false
  end
end
