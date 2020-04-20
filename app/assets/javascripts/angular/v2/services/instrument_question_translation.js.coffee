App.factory 'InstrumentQuestionTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/projects/:project_id/instruments/:instrument_id/instrument_question_translations/?language=:language',
    {project_id: '@project_id', instrument_id: '@instrument_id', language: '@language'},
  )
]
