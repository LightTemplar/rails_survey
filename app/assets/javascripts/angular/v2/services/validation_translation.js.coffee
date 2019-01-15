App.factory 'ValidationTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/validation_translations/:id/:memberRoute?language=:language&validation_id=:validation_id',
    {id: '@id', language: '@language', memberRoute: '@memberRoute', validation_id: '@validation_id'},
    {update: {method: 'PUT'},
    batch_update: {method: 'POST', params: {memberRoute: 'batch_update'}}
    }
  )
]
