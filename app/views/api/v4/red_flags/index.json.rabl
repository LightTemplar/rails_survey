# frozen_string_literal: true

collection @red_flags

attributes :id, :instrument_question_id, :instruction_id, :option_identifier,
           :selected, :score_scheme_id

node :description, &:description
node :iq_identifier, &:iq_identifier
node :iq_text, &:iq_text
node :option_text, &:option_text
node :section_title, &:section_title
node :display_title, &:display_title
