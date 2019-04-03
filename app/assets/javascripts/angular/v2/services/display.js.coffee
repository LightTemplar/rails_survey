App.factory 'Display', ['$resource', ($resource) ->
  $resource('/api/v2/projects/:project_id/instruments/:instrument_id/displays/:id/:memberRoute',
    {project_id: '@project_id', instrument_id: '@instrument_id', id: '@id', memberRoute: '@memberRoute'},
    {update: {method: 'PUT'},
    copy: {method: 'GET', params: {memberRoute: 'copy'}},
    move: {method: 'POST', params: {memberRoute: 'move'}},
    tabulate: {method: 'GET', params: {memberRoute: 'tabulate'}}
    }
  )
]
