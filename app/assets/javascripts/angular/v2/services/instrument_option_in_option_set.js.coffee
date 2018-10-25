App.factory 'InstrumentOptionInOptionSet', ['$resource', ($resource) ->
  $resource('/api/v2/projects/:project_id/instruments/:instrument_id/instrument_option_in_option_sets',
    {project_id: '@project_id', instrument_id: '@instrument_id'}
  )
]
