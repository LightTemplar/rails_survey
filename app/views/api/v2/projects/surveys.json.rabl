# frozen_string_literal: true

collection @projects

attributes :id, :name, :description

child :instruments do
  attributes :id, :title, :language, :alignment, :project_id, :published

  node :version_number, &:current_version_number

  node :question_count do |i|
    i.instrument_questions.count
  end
end

child :surveys do
  attributes :id, :uuid, :instrument_id, :instrument_title, :instrument_version_number,
             :device_user_id, :completed, :metadata, :updated_at

  child :responses do
    attributes :id, :uuid, :survey_uuid, :question_identifier, :question_id,
               :text, :special_response, :other_text, :other_response,
               :time_started, :time_ended, :device_user_id, :identifies_survey
  end
end
