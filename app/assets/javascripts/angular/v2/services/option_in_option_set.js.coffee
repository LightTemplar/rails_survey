App.factory 'OptionInOptionSet', ['$resource', ($resource) ->
  $resource('/api/v2/option_in_option_sets/:id?option_set_id=:option_set_id&instrument_id=:instrument_id',
    {id: '@id', option_set_id: '@option_set_id', instrument_id: '@instrument_id' },
    {update: {method: 'PUT'}}
  )
]
