# frozen_string_literal: true

object @response

attributes :id, :uuid, :question_identifier, :text, :special_response,
           :other_response, :time_started, :time_ended, :survey_uuid

node :created_at do |r|
  r.created_at.strftime('%m/%d/%Y')
end
