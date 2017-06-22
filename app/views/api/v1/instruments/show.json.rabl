object @instrument
cache @instrument
extends 'api/templates/instrument'
# child :translations, if: ->(t) { t.active_translations } do
child :translations do
  extends 'api/child_templates/instrument_translation'
end
