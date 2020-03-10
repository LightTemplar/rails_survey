# frozen_string_literal: true

collection @follow_up_questions
cache ['v3-follow-up-questions', @follow_up_questions]

attributes :id, :question_identifier, :following_up_question_identifier, :position

node :question_id, &:instrument_question_id

node :instrument_id do |fuq|
  fuq.instrument_question&.instrument_id
end
