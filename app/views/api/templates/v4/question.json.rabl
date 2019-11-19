# frozen_string_literal: true

attributes :id, :question_identifier, :parent_identifier, :folder_id, :question_type,
           :text, :option_set_id, :special_option_set_id, :instruction_id, :identifies_survey,
           :question_set_id, :validation_id, :rank_responses

child :instruction do
  extends 'api/v4/instructions/show'
end
