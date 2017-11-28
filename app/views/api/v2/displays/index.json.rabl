collection @displays
cache ['v2-displays', @displays]

attributes :id, :position, :mode, :instrument_id

child :instrument_questions do
  node :identifier do |iq|
    iq.question.question_identifier
  end

  node :type do |iq|
    iq.question.question_type
  end
end
