App.factory 'Instrument', ['$resource', ($resource) ->
  $resource '/api/v2/projects/:project_id/instruments/:id/:memberRoute',
  { project_id: '@project_id', id: '@id', memberRoute: '@memberRoute' },
  { update: { method: 'PUT' },
  copy: {method: 'GET', params: {memberRoute: 'copy'}},
  reorder: {method: 'POST', params: {memberRoute: 'reorder'}},
  importSkipPatterns: {method: 'GET', params: {memberRoute: 'set_skip_patterns'}},
  reorderDisplays: {method: 'POST', params: {memberRoute: 'reorder_displays'}}
  }
]
