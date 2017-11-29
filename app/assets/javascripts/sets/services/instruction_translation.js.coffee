App.factory 'InstructionTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/instruction_translations/:id?language=:language',
    {id: '@id', language: '@language'},
    {update: {method: 'PUT'}}
  )
]
