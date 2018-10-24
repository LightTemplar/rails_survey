App.factory 'OptionTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/option_translations/:id/:memberRoute?language=:language&option_set_id=:option_set_id' +
  '&option_id=:option_id&instrument_id=:instrument_id',
  {id: '@id', memberRoute: '@memberRoute', language: '@language', option_set_id: '@option_set_id',
  option_id: '@option_id', instrument_id: '@instrument_id'},
  {update: {method: 'PUT'},
  batch_update: {method: 'POST', params: {memberRoute: 'batch_update'}}
  }
  )
]
