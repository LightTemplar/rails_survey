object @display
cache @display

attributes :id, :position, :mode, :instrument_id, :title, :section_title

node :question_count do |d|
  d.instrument_questions.size
end
