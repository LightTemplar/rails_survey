App.factory 'QuestionSet', ['$resource', ($resource) ->
  $resource('/api/v2/question_sets/:id',
    {id: '@id'},
    {update: {method: 'PUT'}}
  )
]
