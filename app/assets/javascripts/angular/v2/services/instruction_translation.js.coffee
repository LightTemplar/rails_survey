App.factory 'InstructionTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/instruction_translations/:id/:memberRoute?language=:language&instruction_id=:instruction_id',
    {id: '@id', language: '@language', memberRoute: '@memberRoute', instruction_id: '@instruction_id'},
    {update: {method: 'PUT'},
    batch_update: {method: 'POST', params: {memberRoute: 'batch_update'}}
    }
  )
]
