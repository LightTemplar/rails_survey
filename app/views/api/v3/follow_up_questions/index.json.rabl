collection @follow_up_questions
cache ['v3-follow-up-questions', @follow_up_questions]

attributes :id, :question_identifier, :following_up_question_identifier, :position

node :question_id do |fuq|
 fuq.instrument_question_id
end

node :instrument_id do |fuq|
  fuq.instrument_question.instrument_id
end
