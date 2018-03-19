collection @instrument, root: 'instrument'
cache ['v4-instrument', @instrument]

attributes :id, :title, :language, :alignment, :project_id, :published

node :question_count do |i|
  i.instrument_questions.count
end

child :translations do
  attributes :id, :instrument_id, :title, :language, :alignment,
  :critical_message, :active
end
