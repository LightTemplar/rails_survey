App.factory 'OptionSet', ['$resource', ($resource) ->
  $resource('/api/v2/option_sets/:id',
    {id: '@id'},
    {update: {method: 'PUT'}}
  )
]
