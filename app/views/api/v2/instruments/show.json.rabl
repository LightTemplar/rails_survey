object @instrument
cache @instrument

attributes :id, :title, :language, :alignment, :project_id, :published

node :display_count do |i|
  i.displays.count
end

node :question_count do |i|
  i.question_count
end