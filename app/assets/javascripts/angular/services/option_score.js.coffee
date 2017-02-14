App.factory 'OptionScore', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/:score_unit_id/option_scores/:id',
    {project_id: '@project_id', score_scheme_id: '@score_scheme_id', score_unit_id: '@score_unit_id', id: '@id'}
  )
]
