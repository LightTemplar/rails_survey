App.controller 'InstrumentQuestionsCtrl', ['$scope', '$routeParams', 'InstrumentQuestion',
'InstrumentQuestions', ($scope, $routeParams, InstrumentQuestion, InstrumentQuestions) ->
  $scope.project_id = $routeParams.project_id
  $scope.instrument_id = $routeParams.instrument_id
  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  }, -> InstrumentQuestions.questions = $scope.instrumentQuestions )

  $scope.sortableInstrumentQuestions = {
    cursor: 'move',
    handle: '.moveInstrumentQuestion',
    axis: 'y',
    stop: (e, ui) ->
      angular.forEach $scope.instrumentQuestions, (instrumentQuestion, index) ->
        instrumentQuestion.number_in_instrument = index + 1
        instrumentQuestion.project_id = $scope.project_id
        instrumentQuestion.instrument_id = $scope.instrument_id
        instrumentQuestion.$update({})
  }

]

App.controller 'ShowInstrumentQuestionCtrl', ['$scope', '$routeParams',
'InstrumentQuestion', 'Setting', 'Option', 'InstrumentQuestions', 'NextQuestion',
($scope, $routeParams, InstrumentQuestion, Setting, Option, InstrumentQuestions,
NextQuestion) ->
  $scope.showNewNextQuestion = false
  $scope.project_id = $routeParams.project_id
  $scope.instrument_id = $routeParams.instrument_id
  # TODO: Does not work if browser refreshed
  $scope.instrumentQuestion = _.first(_.filter(InstrumentQuestions.questions,
    (q) -> q.id == parseInt($routeParams.id)))
  if $scope.instrumentQuestion.option_set_id
    $scope.options = Option.query({
      'option_set_id': $scope.instrumentQuestion.option_set_id
    })
  $scope.settings = Setting.get({})
  $scope.nextQuestions = NextQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.instrumentQuestion.id
  })

  $scope.questionTypesWithSkipPatterns = (questionType) ->
    if $scope.settings.question_with_skips
      questionType in $scope.settings.question_with_skips

  $scope.questionsAfter = (question) ->
    InstrumentQuestions.questions.slice(question.number_in_instrument,
    InstrumentQuestions.questions.length)

  $scope.addNextQuestion = () ->
    $scope.showNewNextQuestion = true
    $scope.newNextQuestion = new NextQuestion()
    $scope.newNextQuestion.instrument_question_id = $scope.instrumentQuestion.id
    $scope.newNextQuestion.question_identifier = $scope.instrumentQuestion.identifier
    $scope.newNextQuestion.project_id = $scope.project_id
    $scope.newNextQuestion.instrument_id = $scope.instrument_id

  $scope.cancel = () ->
    $scope.showNewNextQuestion = false
    $scope.newNextQuestion = null

  $scope.save = () ->
    exists = _.findWhere($scope.nextQuestions, {option_identifier: $scope.newNextQuestion.option_identifier})
    if exists
      alert 'Skip for Option is already set!'
    else
      $scope.newNextQuestion.$save({} ,
        (data, headers) ->
          $scope.nextQuestions.push(data)
          $scope.showNewNextQuestion = false
        (result, headers) ->
      )

  $scope.update = (nextQuestion) ->
    setRouteParameters(nextQuestion)
    exists = _.where($scope.nextQuestions, {option_identifier: nextQuestion.option_identifier})
    if exists.length > 1
      alert 'Skip for Option is already set!'
    else
      nextQuestion.$update({} ,
        (data, headers) ->
        (result, headers) ->
      )

  $scope.delete = (nextQuestion) ->
    if confirm('Are you sure you want to delete this skip pattern?')
      setRouteParameters(nextQuestion)
      if nextQuestion.id
        nextQuestion.$delete({} ,
          (data, headers) ->
            $scope.nextQuestions.splice($scope.nextQuestions.indexOf(nextQuestion), 1)
          (result, headers) ->
        )

  setRouteParameters = (nextQuestion) ->
    nextQuestion.instrument_question_id = $scope.instrumentQuestion.id
    nextQuestion.project_id = $scope.project_id
    nextQuestion.instrument_id = $scope.instrument_id


]
