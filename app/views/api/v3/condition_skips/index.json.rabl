collection @condition_skips
cache ['v3-condition-skips', @condition_skips]

attributes :id, :condition_question_identifier, :condition_option_identifier,
:option_identifier, :condition, :next_question_identifier

node :question_id do |ms|
 ms.instrument_question_id
end

node :question_identifier do |cs|
 cs.instrument_question.identifier
end

node :instrument_id do |ms|
  ms.instrument_question.instrument_id
end
