App.factory 'RandomizedFactor', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/instruments/:instrument_id/randomized_factors/:id', {project_id: '@project_id', instrument_id: '@instrument_id', id: '@id'}, {update: {method: 'PUT'}}
  )
]
