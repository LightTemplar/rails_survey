# frozen_string_literal: true

collection @displays
cache ['v3-displays', @displays]

attributes :id, :mode, :instrument_id, :position, :title, :section_id, :deleted_at

node :question_count, &:instrument_questions_count

child :display_translations do
  attributes :id, :display_id, :text, :language
end
