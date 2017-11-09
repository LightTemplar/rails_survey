object @option
cache @option
extends 'api/templates/randomized_option'

child :translations do
  attributes :id, :instrument_translation_id, :randomized_option_id, :text, :language
end
