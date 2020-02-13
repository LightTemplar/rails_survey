# frozen_string_literal: true

object @instrument_question

attributes :id, :instrument_id, :question_id, :number_in_instrument, :display_id,
           :identifier, :following_up_question_identifier, :table_identifier,
           :carry_forward_identifier, :position, :skip_operation

node :country_list, &:country_list

child :question do
  extends 'api/templates/v4/question'
end

child non_special_options: :options do
  extends 'api/templates/v4/option'
end

child special_options: :special_options do |_q|
  extends 'api/templates/v4/option'
end
