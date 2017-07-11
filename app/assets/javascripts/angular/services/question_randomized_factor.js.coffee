App.factory 'QuestionRandomizedFactor', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/instruments/:instrument_id/questions/:question_id/question_randomized_factors/:id', {project_id: '@project_id', instrument_id: '@instrument_id', question_id: '@question_id', id: '@id'}, {update: {method: 'PUT'}}
  )
]
