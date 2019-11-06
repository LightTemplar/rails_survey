# frozen_string_literal: true

object @survey

attributes :id, :instrument_id, :instrument_title, :uuid, :completion_rate,
           :completed_responses_count, :device_label

node :project_name, &:project_name

node :identifier, &:identifier

node :location, &:location

node :created_at do |s|
  s.created_at.strftime('%m/%d/%Y')
end

node :received_responses_count do |s|
  s.responses.size
end
