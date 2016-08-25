App.factory 'ScoreScheme', ['$resource', ($resource) ->
  $resource '/api/v1/frontend/projects/:project_id/score_schemes/:id', { project_id: '@project_id', id: '@id' }
]

App.factory 'ScoreUnit', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/:id',
    {project_id: '@project_id', score_scheme_id: '@score_scheme_id', id: '@id'},
    {update: {method: 'PUT'}}
  )
]

App.factory 'ScoreUnitQuestions', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/:id/questions',
    {project_id: '@project_id', score_scheme_id: '@score_scheme_id', id: '@id'}
  )
]

App.factory 'ScoreUnitOptions', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/options',
    {project_id: '@project_id', score_scheme_id: '@score_scheme_id'}
  )
]

App.factory 'OptionScore', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/:score_unit_id/option_scores/:id',
    {project_id: '@project_id', score_scheme_id: '@score_scheme_id', score_unit_id: '@score_unit_id', id: '@id'}
  )
]