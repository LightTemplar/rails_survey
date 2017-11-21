collection @options
cache @options

attributes :id, :identifier, :text, :option_set_id, :deleted_at, :number_in_question,
:critical, :complete_survey
# TODO: Set number_in_question when creating option
node :instrument_version_number do |o|
 o.instrument_version
end
