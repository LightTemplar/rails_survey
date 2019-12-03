# frozen_string_literal: true

collection @loop_questions

attributes :id, :instrument_question_id, :parent, :looped, :option_indices, :same_display, :replacement_text

node :looped_position, &:looped_position
