App.factory 'ScoreUnit', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/:id', { project_id: '@project_id', score_scheme_id: '@score_scheme_id', id: '@id'} ,
  { update: { method: 'PUT' } ,
  question_types: { method: 'GET', isArray: true, url: '/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/question_types', params: { project_id: '@project_id', score_scheme_id: '@score_scheme_id'} } ,
  score_types: { method: 'GET', isArray: true, url: '/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/score_types', params: { project_id: '@project_id', score_scheme_id: '@score_scheme_id' } } ,
  options: { method: 'GET', isArray: true, url: '/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/options', params: { project_id: '@project_id', score_scheme_id: '@score_scheme_id' } } ,
  questions: { method: 'GET', isArray: true, url: '/api/v1/frontend/projects/:project_id/score_schemes/:score_scheme_id/score_units/:id/questions', params: { project_id: '@project_id', score_scheme_id: '@score_scheme_id', id: '@id' } }
  } )
]