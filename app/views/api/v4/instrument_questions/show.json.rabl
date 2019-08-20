# frozen_string_literal: true

object @instrument_question

extends 'api/templates/v4/instrument_question'

child :non_special_options do
  extends 'api/templates/v4/option'
end
