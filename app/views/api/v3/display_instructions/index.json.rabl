collection @display_instructions
cache ['v3-display-instructions', @display_instructions]

attributes :id, :position, :display_id, :instruction_id, :deleted_at

node :position do |di|
  if di.position.nil?
    di.instrument_question.position if di.instrument_question
  else
    di.position
  end
end
