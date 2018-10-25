object @instrument
cache @instrument

attributes :id, :title, :language, :alignment, :project_id, :published, :created_at, :updated_at, :current_version_number

node :display_count do |i|
  i.displays.count
end

node :question_count do |i|
  i.question_count
end

node :language_name do |i|
  Settings.languages.to_h.key(i.language)
end
