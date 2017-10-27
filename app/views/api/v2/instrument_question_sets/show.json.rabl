object @instrument_question_set
cache @instrument_question_set

attributes :id, :instrument_id, :question_set_id

node :question_set_title do |iqs|
  iqs.question_set.title
end
