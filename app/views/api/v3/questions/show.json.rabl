# frozen_string_literal: true

object @question
cache @question

attributes :id, :instrument_id, :display_id, :number_in_instrument, :deleted_at, :table_identifier, :question_id

node :text do |iq|
  iq.question&.text
end

node :question_type do |iq|
  iq.question&.question_type
end

node :question_identifier, &:identifier

node :instruction_id do |iq|
  iq.question&.try(:instruction_id)
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

child :translations do |_t|
  attributes :id, :question_id, :text, :language, :instructions
end
