App.factory 'ScoreScheme', ['$resource', ($resource) ->
  $resource '/api/v1/frontend/projects/:project_id/score_schemes/:id', { project_id: '@project_id', id: '@id' }
]
