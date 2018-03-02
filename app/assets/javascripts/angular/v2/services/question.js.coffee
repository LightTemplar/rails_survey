App.factory 'Question', ['$resource', ($resource) ->
  $resource('/api/v2/question_sets/:question_set_id/questions/:id/:memberRoute',
    {question_set_id: '@question_set_id', id: '@id', memberRoute: '@memberRoute'},
    {update: {method: 'PUT'},
    copy: {method: 'GET', params: {memberRoute: 'copy'}}
    }
  )
]
