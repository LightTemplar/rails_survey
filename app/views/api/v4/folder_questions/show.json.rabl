# frozen_string_literal: true

object @question

extends 'api/templates/v4/question'

node :instructions do |q|
  q.instruction&.text
end

child options: :options do |_q|
  extends 'api/templates/v4/option'
end

child special_options: :special_options do |_q|
  extends 'api/templates/v4/option'
end
