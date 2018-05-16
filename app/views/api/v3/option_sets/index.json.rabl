collection @option_sets
cache ['v3-option-sets', @option_sets]

attributes :id, :deleted_at, :title, :special

node :instructions do |os|
  os.instruction.try(:text)
end
