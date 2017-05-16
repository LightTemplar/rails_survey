object @instrument
cache @instrument
extends 'api/templates/instrument'

node :non_grid_question_count do |i|
  i.questions.where(grid_id: nil).count
end

child :randomized_factors do
  extends 'api/templates/randomized_factor'
end

child :randomized_options do
  extends 'api/templates/randomized_option'
end
