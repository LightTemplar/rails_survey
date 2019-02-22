# frozen_string_literal: true

object @display_instruction
cache @display_instruction

attributes :id, :instrument_question_id, :display_id, :instruction_id

node :audible_list, &:audible_list
