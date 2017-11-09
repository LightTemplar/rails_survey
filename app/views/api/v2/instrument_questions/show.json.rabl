object @instrument_question
cache @instrument_question

attributes :id, :instrument_id, :question_id, :number_in_instrument, :display_id

node :identifier do |iq|
  iq.question.question_identifier
end

node :type do |iq|
  iq.question.question_type
end

node :text do |iq|
  iq.question.text
end

node :question_set_id do |iq|
  iq.question.question_set_id
end

node :option_set_id do |iq|
  iq.question.option_set_id
end

child :display do |iq|
  attributes :id, :position, :mode
end
