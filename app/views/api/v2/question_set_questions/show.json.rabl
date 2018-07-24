object @question
cache @question

attributes :id, :question_identifier, :parent_identifier, :folder_id, :question_type, :text, :option_set_id,
:special_option_set_id, :instruction_id, :identifies_survey, :critical, :question_set_id, :validation_id

node :sum_of_parts do |q|
  q.sum_of_parts.to_f
end

child :instruments do |q|
  attributes :id, :title, :project_id
end
