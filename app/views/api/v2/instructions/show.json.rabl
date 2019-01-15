object @instruction
cache @instruction

attributes :id, :title, :text

child :questions do |instruction|
  attributes :id, :question_identifier, :question_set_id, :text
end

child :option_sets do |instruction|
  attributes :id, :title
end
