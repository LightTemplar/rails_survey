App.factory 'CriticalResponse', ['$resource', ($resource) ->
  $resource('/api/v2/question_sets/:question_set_id/questions/:question_id/critical_responses/:id',
    {question_set_id: '@question_set_id', question_id: '@question_id', id: '@id'},
    {update: {method: 'PUT'}}
  )
]
