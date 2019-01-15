App.factory 'Rule', ['$resource', ($resource) ->
  $resource('/api/v2/rules/:id',
    {id: '@id'},
    {update: {method: 'PUT'}}
  )
]
