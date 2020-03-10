# frozen_string_literal: true

collection @sections
cache ['v3-sections', @sections]

attributes :id, :title, :instrument_id, :deleted_at

child :translations do
  attributes :id, :section_id, :text, :language
end
