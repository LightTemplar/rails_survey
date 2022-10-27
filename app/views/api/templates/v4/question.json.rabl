# frozen_string_literal: true

attributes :id, :question_identifier, :parent_identifier, :folder_id, :question_type,
           :text, :option_set_id, :special_option_set_id, :instruction_id, :identifies_survey,
           :question_set_id, :validation_id, :rank_responses, :pdf_response_height,
           :pdf_print_options, :pop_up_instruction_id, :after_text_instruction_id,
           :default_response, :position, :task_id, :record_audio

child :instruction do
  extends 'api/v4/instructions/show'
end

child :diagrams do |_d|
  attributes :id, :option_id, :question_id, :position, :deleted_at
end
