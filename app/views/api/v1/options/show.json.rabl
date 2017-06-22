object @option
cache @option
extends 'api/templates/option'
# child :translations, if: ->(t) { t.active_translations } do
child :translations do
  extends 'api/child_templates/option_translation'
end
