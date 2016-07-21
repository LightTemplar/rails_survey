App.factory 'ScoreUnit', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/:id',
    {project_id: '@project_id', score_scheme_id: '@score_scheme_id', id: '@id'}
  )
]

App.factory 'ScoreUnitQuestions', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/:id/questions',
    {project_id: '@project_id', score_scheme_id: '@score_scheme_id', id: '@id'}
  )
]