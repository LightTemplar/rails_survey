App.factory 'OptionTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/option_translations/:id/:memberRoute?language=:language&option_set_id=:option_set_id',
    {id: '@id', language: '@language', memberRoute: '@memberRoute', option_set_id: '@option_set_id'},
    {update: {method: 'PUT'},
    batch_update: {method: 'POST', params: {memberRoute: 'batch_update'}}
    }
  )
]
