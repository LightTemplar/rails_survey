object @instrument_translation
cache @instrument_translation
extends 'api/child_templates/instrument_translation'

child :grid_translations do
  extends 'api/child_templates/grid_translation'
end

child :grid_label_translations do
  extends 'api/child_templates/grid_label_translation'
end
