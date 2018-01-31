collection @next_questions
cache ['v3-next-questions', @next_questions]

attributes :id, :question_identifier, :option_identifier, :next_question_identifier

node :question_id do |nq|
 nq.instrument_question_id
end

node :instrument_id do |nq|
  nq.instrument_question.instrument_id
end
