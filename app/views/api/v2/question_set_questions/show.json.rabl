object @question
cache @question

attributes :id, :question_identifier, :parent_identifier, :folder_id, :question_type, :text, :option_set_id,
:special_option_set_id, :instruction_id, :identifies_survey, :critical, :question_set_id, :validation_id

child :instruments do |q|
  attributes :id, :title, :project_id
end
