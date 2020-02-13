# frozen_string_literal: true

collection @display_instructions

attributes :id, :position, :display_id, :instruction_id, :deleted_at

node :position do |di|
  if di.position.nil?
    di.instrument_question&.position
  else
    di.position
  end
end
