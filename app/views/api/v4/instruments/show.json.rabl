# frozen_string_literal: true

object @instrument
cache @instrument

attributes :id, :title, :language, :alignment, :project_id, :published, :created_at, :updated_at, :current_version_number

node :display_count do |i|
  i.displays.count
end

node :question_count, &:question_count

node :language_name do |i|
  Settings.languages.to_h.key(i.language)
end

node :project do |i|
  i.project.name
end

child :sections do
  extends 'api/templates/v4/section'
end

child :displays do
  extends 'api/templates/v4/display'
end
