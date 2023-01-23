# frozen_string_literal: true

collection @sections

attributes :id, :title, :instrument_id, :deleted_at, :position, :randomize_displays

child :translations do
  attributes :id, :section_id, :text, :language
end
