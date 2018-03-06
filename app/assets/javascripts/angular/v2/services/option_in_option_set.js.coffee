App.factory 'OptionInOptionSet', ['$resource', ($resource) ->
  $resource('/api/v2/option_sets/:option_set_id/option_in_option_sets/:id',
    {option_set_id: '@option_set_id', id: '@id'},
    {update: {method: 'PUT'}}
  )
]
