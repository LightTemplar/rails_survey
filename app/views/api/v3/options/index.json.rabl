collection @options
cache ['v3-options', @options]

attributes :id, :identifier, :text, :deleted_at, :critical, :complete_survey

node :instrument_version_number do |o|
 -1
end

child :translations do
  attributes :id, :option_id, :text, :language
end
