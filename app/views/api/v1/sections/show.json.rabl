object @section

attributes :id, :title, :instrument_id, :created_at, :updated_at, :deleted_at, :first_question_number

child :translations do
  attributes :id, :section_id, :text, :created_at, :updated_at, :language, :section_changed
end
