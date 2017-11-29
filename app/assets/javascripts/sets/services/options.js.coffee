App.factory 'Options', ['$resource', ($resource) ->
  $resource('/api/v2/options/:id',
    {id: '@id'},
    {update: {method: 'PUT'}}
  )
]
