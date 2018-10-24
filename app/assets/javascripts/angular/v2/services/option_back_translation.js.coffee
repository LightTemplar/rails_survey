App.factory 'OptionBackTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/option_back_translations/:id/:memberRoute?language=:language&option_set_id=:option_set_id' +
      '&option_translation_id=:option_translation_id&instrument_id=:instrument_id',
    {id: '@id', language: '@language', option_set_id: '@option_set_id',
    option_translation_id: '@option_translation_id', instrument_id: '@instrument_id',
    memberRoute: '@memberRoute'},
    {update: {method: 'PUT'},
    batch_update: {method: 'POST', params: {memberRoute: 'batch_update'}}
    }
  )
]
