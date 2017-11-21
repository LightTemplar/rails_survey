collection @sections
cache @sections

attributes :id, :title, :instrument_id, :deleted_at, :first_question_number

node :first_question_number do |s|
  s.first_question_number
end

child :translations do
  attributes :id, :section_id, :text, :language, :section_changed, :instrument_translation_id
end
