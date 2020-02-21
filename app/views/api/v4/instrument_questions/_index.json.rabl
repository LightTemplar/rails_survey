# frozen_string_literal: true

collection @instrument_questions

attributes :id, :instrument_id, :question_id, :number_in_instrument, :display_id,
           :identifier, :following_up_question_identifier, :table_identifier,
           :carry_forward_identifier, :position, :next_question_neutral_ids,
           :next_question_operator, :multiple_skip_operator, :multiple_skip_neutral_ids

node :question_type, &:question_type
