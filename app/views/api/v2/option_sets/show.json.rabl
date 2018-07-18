object @option_set
cache @option_set

attributes :id, :title, :instruction_id, :special

child :questions do |os|
  attributes :id, :question_identifier, :question_set_id
end