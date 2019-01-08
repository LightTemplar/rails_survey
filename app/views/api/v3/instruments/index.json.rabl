collection @instruments
cache ['v3-instruments', @instruments]

attributes :id, :title, :language, :alignment, :child_update_count, :roster,
:previous_question_count, :deleted_at, :project_id, :published, :special_options,
:show_sections_page, :scorable, :navigate_to_review_page

node :current_version_number do |i|
  i.current_version_number
end

node :question_count do |i|
  i.instrument_questions.count
end

child :translations do
  attributes :id, :instrument_id, :title, :language, :alignment, :active
end
