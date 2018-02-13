App.factory 'Project', ['$resource', ($resource) ->
  $resource('/api/v2/projects/:id', {id: '@id'})
]
