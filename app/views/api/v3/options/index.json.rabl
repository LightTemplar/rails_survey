collection @options
cache ['v3-options', @options]

attributes :id, :identifier, :text, :option_set_id, :deleted_at, :number_in_question,
:critical, :complete_survey, :special

node :instrument_version_number do |o|
 o.instrument_version
end

child :translations do
  attributes :id, :option_id, :text, :language
end
