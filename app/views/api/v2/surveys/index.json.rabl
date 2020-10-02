# frozen_string_literal: true

collection @surveys

attributes :id, :uuid, :instrument_id, :instrument_title, :instrument_version_number,
           :device_user_id, :completed, :metadata, :updated_at, :language, :skipped_questions

node :project_name, &:project_name
node :project_id, &:project_id
node :identifier, &:identifier

child :responses do
  attributes :id, :uuid, :survey_uuid, :question_identifier, :question_id,
             :text, :special_response, :other_text, :other_response,
             :time_started, :time_ended, :device_user_id, :identifies_survey
end

child :instrument do
  attributes :id, :title, :language, :alignment, :project_id, :published

  node :version_number, &:current_version_number

  node :question_count do |i|
    i.instrument_questions.count
  end
end
