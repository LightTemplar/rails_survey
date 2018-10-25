App.factory 'InstrumentOption', ['$resource', ($resource) ->
  $resource('/api/v2/projects/:project_id/instruments/:instrument_id/instrument_options',
    {project_id: '@project_id', instrument_id: '@instrument_id'}
  )
]
