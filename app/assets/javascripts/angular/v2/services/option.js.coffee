App.factory 'Option', ['$resource', ($resource) ->
  $resource('/api/v2/option_sets/:option_set_id/options/:id',
    {option_set_id: '@option_set_id', id: '@id'},
    {update: {method: 'PUT'}}
  )
]
