App.factory 'InstrumentNextQuestion', ['$resource', ($resource) ->
  $resource('/api/v2/projects/:project_id/instruments/:instrument_id/next_questions/',
    {project_id: '@project_id', instrument_id: '@instrument_id'}
  )
]
