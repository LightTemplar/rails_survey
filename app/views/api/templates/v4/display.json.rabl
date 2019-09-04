# frozen_string_literal: true

attributes :id, :position, :mode, :instrument_id, :title, :section_id, :instrument_questions_count

node :section_title do |d|
  d&.section&.title
end
