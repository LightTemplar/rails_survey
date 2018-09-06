App.factory 'Section', ['$resource', ($resource) ->
  $resource('/api/v2/projects/:project_id/instruments/:instrument_id/sections/:id',
    {project_id: '@project_id', instrument_id: '@instrument_id', id: '@id'},
    {update: {method: 'PUT'}}
  )
]
