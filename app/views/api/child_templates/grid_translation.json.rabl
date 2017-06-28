cache root_object
extends 'api/templates/grid_translation'

node :grid_name do |grid_translation|
  grid_translation.grid.name
end

node :grid_instructions do |grid_translation|
  grid_translation.grid.instructions
end
