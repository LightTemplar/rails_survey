cache root_object
extends 'api/templates/grid_label_translation'

node :grid_label_label do |grid_label_translation|
  grid_label_translation.grid_label.label
end

node :grid_label_grid_id do |grid_label_translation|
  grid_label_translation.grid_label.grid_id
end