App.factory 'Questions', ['$resource', ($resource) ->
  $resource('/api/v2/questions/')
]
