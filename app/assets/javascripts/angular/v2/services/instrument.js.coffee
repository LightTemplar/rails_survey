App.factory 'Instrument', ['$resource', ($resource) ->
  $resource '/api/v2/projects/:project_id/instruments/:id',
  { project_id: '@project_id', id: '@id' },
  { update: { method: 'PUT' } }
]
