App.factory 'QuestionBackTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/question_back_translations/:id/:memberRoute?language=:language&question_set_id=:question_set_id' +
      '&question_translation_id=:question_translation_id&instrument_id=:instrument_id&question_id=:question_id',
    {id: '@id', language: '@language', question_set_id: '@question_set_id', question_translation_id: '@question_translation_id',
    memberRoute: '@memberRoute', instrument_id: '@instrument_id', question_id: '@question_id'},
    {update: {method: 'PUT'},
    batch_update: {method: 'POST', params: {memberRoute: 'batch_update'}}
    }
  )
]
