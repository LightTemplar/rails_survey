App.factory 'SectionTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/projects/:project_id/instruments/:instrument_id/section_translations/:memberRoute',
    {project_id: '@project_id', instrument_id: '@instrument_id', memberRoute: '@memberRoute'},
    batch_update: {method: 'POST', params: {memberRoute: 'batch_update'}}
  )
]
