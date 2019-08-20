# frozen_string_literal: true

object @display

extends 'api/templates/v4/display'

child :instrument_questions do
  extends 'api/v4/instrument_questions/show'
end
