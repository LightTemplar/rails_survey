# frozen_string_literal: true

collection @condition_skips

attributes :id, :condition_question_identifier, :condition_option_identifier,
           :option_identifier, :condition, :next_question_identifier, :deleted_at

node :question_id, &:instrument_question_id

node :question_identifier do |cs|
  cs.instrument_question&.identifier
end

node :instrument_id do |ms|
  ms.instrument_question&.instrument_id
end
