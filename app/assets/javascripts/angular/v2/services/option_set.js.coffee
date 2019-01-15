App.factory 'OptionSet', ['$resource', ($resource) ->
  $resource('/api/v2/option_sets/:id/:memberRoute',
    {id: '@id', memberRoute: '@memberRoute'},
    { update: {method: 'PUT'},
    copy: {method: 'GET', params: {memberRoute: 'copy'}}
    }
  )
]
