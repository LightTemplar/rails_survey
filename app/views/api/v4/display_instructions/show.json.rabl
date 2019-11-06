# frozen_string_literal: true

object @display_instruction

attributes :id, :position, :display_id, :instruction_id

node :position do |di|
  if di.position.nil?
    di.instrument_question&.position
  else
    di.position
  end
end

node :instructions do |di|
  di.instruction.text
end
