App.factory 'Setting', ['$resource', ($resource) ->
  $resource('/api/v2/settings/index')
]
