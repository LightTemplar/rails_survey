# frozen_string_literal: true

collection @sections

attributes :id, :title, :instrument_id, :position

child :displays do
  attributes :id, :position, :instrument_id, :title, :section_id, :instrument_position, :instrument_questions_count
end
