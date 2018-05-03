collection @next_questions
cache ['v2-instrument-next-questions', @next_questions]

attributes :question_identifier, :next_question_identifier, :option_identifier

node :question_number do |nq|
  nq.instrument_question.number_in_instrument
end
