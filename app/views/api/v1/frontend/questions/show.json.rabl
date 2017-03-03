object @question
cache @question
extends 'api/templates/question'

node :project_id do |q|
  q.instrument.project_id
end

child :options do
  extends 'api/child_templates/option'
end
# Alias child as option_skips to avoid it showing up as skips
child option_skips: :option_skips do
  extends 'api/child_templates/option_skip'
end

child :images do
  extends 'api/child_templates/image'
end
