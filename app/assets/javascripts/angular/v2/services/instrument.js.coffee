App.factory 'Instrument', ['$resource', ($resource) ->
  $resource '/api/v2/projects/:project_id/instruments/:id/:memberRoute',
  { project_id: '@project_id', id: '@id', memberRoute: '@memberRoute' },
  { update: { method: 'PUT' },
  copy: {method: 'GET', params: {memberRoute: 'copy'}},
  reorder: {method: 'GET', params: {memberRoute: 'reorder'}}
  }
]
