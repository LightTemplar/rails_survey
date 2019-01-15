collection @displays
cache ['v3-displays', @displays]

attributes :id, :mode, :instrument_id, :position, :title, :section_id, :deleted_at

child :display_translations do
  attributes :id, :display_id, :text, :language
end
