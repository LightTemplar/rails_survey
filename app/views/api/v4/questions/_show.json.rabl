# frozen_string_literal: true

object @question

attributes :id, :question_identifier, :parent_identifier, :folder_id, :question_type,
           :text, :option_set_id, :special_option_set_id, :instruction_id, :identifies_survey,
           :question_set_id, :validation_id, :rank_responses, :pdf_response_height,
           :pdf_print_options, :pop_up_instruction_id, :after_text_instruction_id,
           :default_response, :position

node :question_set_title, &:question_set_title
node :folder_title, &:folder_title
