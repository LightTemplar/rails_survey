App.factory 'Question', ['$resource', ($resource) ->
  $resource('/api/v2/question_sets/:question_set_id/questions/:id',
    {question_set_id: '@question_set_id', id: '@id'},
    {update: {method: 'PUT'}}
  )
]
