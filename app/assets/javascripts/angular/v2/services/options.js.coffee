App.factory 'Options', ['$resource', ($resource) ->
  $resource('/api/v2/options/:id?instrument_id=:instrument_id',
    {id: '@id', instrument_id: '@instrument_id'},
    {update: {method: 'PUT'}}
  )
]
