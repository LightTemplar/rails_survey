object @section
cache ['v1', @section]
attributes :id, :title, :instrument_id, :created_at, :updated_at, :deleted_at, :first_question_number

child :translations do
  extends 'api/translations/section'
end
