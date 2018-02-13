App.factory 'OptionTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/option_translations/:id?language=:language',
    {id: '@id', language: '@language'},
    {update: {method: 'PUT'}}
  )
]
