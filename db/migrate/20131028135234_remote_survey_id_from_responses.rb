class RemoteSurveyIdFromResponses < ActiveRecord::Migration[4.2]
  def change
    remove_column :responses, :survey_id
  end
end
