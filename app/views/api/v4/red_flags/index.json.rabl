# frozen_string_literal: true

collection @red_flags

attributes :id, :option_identifier, :instruction_id, :selected, :instrument_question_id

node :description, &:description
