# frozen_string_literal: true

attributes :id, :instrument_id, :question_id, :number_in_instrument, :display_id,
           :identifier, :following_up_question_identifier, :table_identifier

node :country_list, &:country_list

node :type do |iq|
  iq.question&.question_type
end

node :text do |iq|
  iq.question&.text
end

node :question_set_id do |iq|
  iq.question&.question_set_id
end

node :option_set_id do |iq|
  iq.question&.option_set_id
end

node :special_option_set_id do |iq|
  iq.question&.special_option_set_id
end
