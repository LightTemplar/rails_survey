# frozen_string_literal: true

collection @instruments

attributes :id, :title, :language, :alignment, :project_id, :published

node :version_number, &:current_version_number

node :question_count do |i|
  i.instrument_questions.count
end
