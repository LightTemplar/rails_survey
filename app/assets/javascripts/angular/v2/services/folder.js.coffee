App.factory 'Folder', ['$resource', ($resource) ->
  $resource('/api/v2/question_sets/:question_set_id/folders/:id',
    {question_set_id: '@question_set_id', id: '@id'},
    {update: {method: 'PUT'}}
  )
]
