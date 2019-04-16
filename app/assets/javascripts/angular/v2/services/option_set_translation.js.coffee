App.factory 'OptionSetTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/option_sets/:option_set_id/option_set_translations/:id',
    {option_set_id: '@option_set_id', id: '@id'},
    { update: {method: 'PUT'}}
  )
]
