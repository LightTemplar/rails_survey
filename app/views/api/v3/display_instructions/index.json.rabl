collection @display_instructions
cache ['v3-display-instructions', @display_instructions]

attributes :id, :position, :display_id

node :deleted do |di|
 di.deleted_at ? true : false
end

node :instructions do |di|
  di.instruction.text if di.instruction
end
