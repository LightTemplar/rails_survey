# frozen_string_literal: true

collection @instrument_questions

attributes :id, :instrument_id, :question_id, :number_in_instrument, :display_id,
           :identifier, :following_up_question_identifier, :table_identifier,
           :carry_forward_identifier, :position, :next_question_neutral_ids,
           :next_question_operator, :multiple_skip_operator, :show_number,
           :multiple_skip_neutral_ids

node :question_type, &:question_type

node :option_set_id, &:option_set_id

node :text, &:text

node :before_text_instruction, &:before_text_instruction

node :after_text_instruction, &:after_text_instruction

node :pop_up_instruction_text, &:pop_up_instruction_text

node :section_title, &:section_title

node :display_title, &:display_title

child non_special_options: :options do
  attributes :id, :text, :identifier
end

child special_options: :special_options do
  attributes :id, :text, :identifier
end
