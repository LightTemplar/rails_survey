class AddSurveyUuidToResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :survey_uuid, :string
  end
end
