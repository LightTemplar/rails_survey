# frozen_string_literal: true

collection @multiple_skips

attributes :id, :question_identifier, :option_identifier,
           :skip_question_identifier, :deleted_at, :value, :value_operator

node :question_id, &:instrument_question_id

node :instrument_id do |ms|
  ms.instrument_question&.instrument_id
end

node :question_identifier do |ms|
  if ms.question_identifier.nil?
    ms.instrument_question&.identifier
  else
    ms.question_identifier
  end
end
