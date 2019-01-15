App.factory 'DisplayInstruction', ['$resource', ($resource) ->
  $resource('/api/v2/projects/:project_id/instruments/:instrument_id/displays/:display_id/display_instructions/:id',
    {project_id: '@project_id', instrument_id: '@instrument_id', display_id: '@display_id', id: '@id'},
    {update: {method: 'PUT'}}
  )
]
