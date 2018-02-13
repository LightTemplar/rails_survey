App.factory 'QuestionTranslation', ['$resource', ($resource) ->
  $resource('/api/v2/question_translations/:id?language=:language',
    {id: '@id', language: '@language'},
    {update: {method: 'PUT'}}
  )
]
