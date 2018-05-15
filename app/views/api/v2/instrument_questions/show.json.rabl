object @instrument_question
cache @instrument_question

attributes :id, :instrument_id, :question_id, :number_in_instrument, :display_id,
:identifier, :following_up_question_identifier

node :type do |iq|
  iq.question.question_type if iq.question
end

node :text do |iq|
  iq.question.text if iq.question
end

node :question_set_id do |iq|
  iq.question.question_set_id if iq.question
end

node :option_set_id do |iq|
  iq.question.option_set_id if iq.question
end

node :special_option_set_id do |iq|
  iq.question.special_option_set_id if iq.question
end
