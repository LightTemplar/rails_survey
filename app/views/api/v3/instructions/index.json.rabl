collection @instructions
cache ['v3-instructions', @instructions]

attributes :id, :text, :deleted_at

child :instruction_translations do |t|
  attributes :id, :instruction_id, :text, :language
end
