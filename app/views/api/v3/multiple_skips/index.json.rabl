collection @multiple_skips
cache ['v3-multiple-skips', @multiple_skips]

attributes :id, :question_identifier, :option_identifier, :skip_question_identifier

node :question_id do |ms|
 ms.instrument_question_id
end

node :instrument_id do |ms|
  ms.instrument_question.instrument_id
end