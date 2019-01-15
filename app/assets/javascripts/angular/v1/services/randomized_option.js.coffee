App.factory 'RandomizedOption', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/instruments/:instrument_id/randomized_factors/:randomized_factor_id/randomized_options/:id', {project_id: '@project_id', instrument_id: '@instrument_id', randomized_factor_id: '@randomized_factor_id', id: '@id'}, {update: {method: 'PUT'}}
  )
]
