# frozen_string_literal: true

collection @follow_up_questions

attributes :id, :question_identifier, :following_up_question_identifier, :position, :deleted_at

node :question_id, &:instrument_question_id

node :instrument_id do |fuq|
  fuq.instrument_question&.instrument_id
end
