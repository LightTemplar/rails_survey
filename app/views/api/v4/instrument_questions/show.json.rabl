# frozen_string_literal: true

object @instrument_question

extends 'api/templates/v4/instrument_question'

node :instructions do |q|
  q&.question&.instruction&.text
end

child non_special_options: :options do
  extends 'api/templates/v4/option'
end

child special_options: :special_options do |_q|
  extends 'api/templates/v4/option'
end
