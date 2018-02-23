collection @instruments
cache ['v2-instruments', @instruments]

attributes :id, :title, :language, :alignment, :child_update_count, :roster,
:previous_question_count, :deleted_at, :project_id, :published, :special_options,
:show_sections_page, :scorable, :navigate_to_review_page, :critical_message,
:created_at, :updated_at

node :current_version_number do |i|
  i.current_version_number
end

node :question_count do |i|
  i.question_count
end
