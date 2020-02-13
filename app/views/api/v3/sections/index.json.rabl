# frozen_string_literal: true

collection @sections

attributes :id, :title, :instrument_id, :deleted_at, :position

child :translations do
  attributes :id, :section_id, :text, :language
end
