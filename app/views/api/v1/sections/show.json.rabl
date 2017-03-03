object @section
cache @section
attributes :id, :title, :instrument_id, :created_at, :updated_at, :deleted_at, :first_question_number

child :translations do
  extends 'api/child_templates/section_translation'
end
