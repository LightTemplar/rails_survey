object @question
cache @question
extends 'api/templates/question'
# child :translations, if: ->(t) { t.active_translations } do
child :translations do
  extends 'api/child_templates/question_translation'
end
