App.factory 'Instruction', ['$resource', ($resource) ->
  $resource('/api/v2/instructions/:id',
    {id: '@id'},
    {update: {method: 'PUT'}}
  )
]
