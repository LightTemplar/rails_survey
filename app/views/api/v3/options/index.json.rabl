# frozen_string_literal: true

collection @options
cache ['v3-options', @options]

attributes :id, :identifier, :text, :deleted_at

node :instrument_version_number do |_o|
  -1
end

child :translations do
  attributes :id, :option_id, :text, :language
end
