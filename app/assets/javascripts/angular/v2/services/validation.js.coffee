App.factory 'Validation', ['$resource', ($resource) ->
  $resource('/api/v2/validations/:id',
    {id: '@id'},
    {update: {method: 'PUT'}}
  )
]
