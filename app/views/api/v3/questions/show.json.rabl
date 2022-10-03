# frozen_string_literal: true

object @question

attributes :id, :instrument_id, :display_id, :number_in_instrument, :deleted_at,
           :table_identifier, :question_id, :carry_forward_identifier, :position,
           :next_question_operator, :multiple_skip_operator,
           :next_question_neutral_ids, :multiple_skip_neutral_ids

node :text do |iq|
  iq.question&.text
end

node :question_type do |iq|
  iq.question&.question_type
end

node :question_identifier, &:identifier

node :has_option_images, &:has_option_images?

node :instruction_id do |iq|
  iq.question&.instruction_id
end

node :instrument_version do |iq|
  iq.instrument&.current_version_number
end

node :question_version do |iq|
  iq.question&.question_version
end

node :option_count do |iq|
  iq.question&.option_count
end

node :image_count do |iq|
  iq.question&.images&.size
end

node :option_set_id do |iq|
  iq.question&.option_set_id
end

node :special_option_set_id do |iq|
  iq.question&.special_option_set_id
end

node :task_id do |iq|
  iq.question&.task_id
end

node :identifies_survey do |iq|
  iq.question&.identifies_survey
end

node :validation_id do |iq|
  iq.question&.validation_id
end

node :rank_responses do |iq|
  iq.question&.rank_responses
end

node :loop_question_count do |iq|
  iq.loop_questions.size
end

node :pop_up_instruction_id do |iq|
  iq.question&.pop_up_instruction_id
end

node :after_text_instruction_id do |iq|
  iq.question&.after_text_instruction_id
end

node :carry_forward_option_set_id do |iq|
  iq.forward_instrument_question&.question&.option_set_id
end

node :default_response do |iq|
  iq.question&.default_response
end

node :has_question_image do |iq|
  iq.question&.has_question_image
end

node :question_image_height do |iq|
  iq.question&.question_image_height
end

child :translations do |_t|
  attributes :id, :question_id, :text, :language, :instructions
end
