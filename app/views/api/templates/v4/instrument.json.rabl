# frozen_string_literal: true

attributes :id, :title, :language, :alignment, :project_id, :published, :created_at, :updated_at, :current_version_number

node :section_count, &:section_count
node :display_count, &:display_count
node :question_count, &:question_count

node :language_name do |i|
  Settings.languages.to_h.key(i.language)
end

node :project do |i|
  i.project.name
end
