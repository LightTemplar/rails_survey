App.factory 'GridLabelTranslation', ['$resource', ($resource) ->
  $resource('/api/v1/frontend/projects/:project_id/instruments/:instrument_id/instrument_translations/:instrument_translation_id/grid_label_translations/:id',
    {project_id: '@project_id', instrument_id: '@instrument_id', instrument_translation_id: '@instrument_translation_id', id: '@id'},
    {update: {method: 'PUT'}}
  )
]