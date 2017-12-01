App.controller 'InstrumentQuestionsCtrl', ['$scope', '$routeParams', '$location',
'$route', 'InstrumentQuestion', 'InstrumentQuestions', 'QuestionSet', 'Question',
($scope, $routeParams, $location, $route, InstrumentQuestion, InstrumentQuestions,
QuestionSet, Question) ->
  $scope.project_id = $routeParams.project_id
  $scope.instrument_id = $routeParams.instrument_id
  $scope.showNewView = false
  $scope.showFromSet = false
  $scope.questions = []

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

  $scope.questionSets = QuestionSet.query({})

  $scope.newInstrumentQuestion = () ->
    $scope.showNewView = true
    $scope.showFromSet = false

  $scope.newIQFromSet = () ->
    $scope.showFromSet = true
    $scope.showNewView = false

  $scope.getQuestions = (questionSetId) ->
    $scope.questions = Question.query({ "question_set_id": questionSetId })

  $scope.next = (questionSetId) ->
    if questionSetId == undefined
      questionSet = new QuestionSet()
      questionSet.title = new Date().getTime().toString()
      questionSet.$save({},
        (data, headers) ->
          $location.path('/question_sets/' + data.id).search({
            instrument_id: $scope.instrument_id,
            project_id: $scope.project_id,
            number_in_instrument: $scope.instrumentQuestions.length + 1
          })
        (result, headers) ->
      )
    else
      $location.path('/question_sets/' + questionSetId).search({
        instrument_id: $scope.instrument_id,
        project_id: $scope.project_id,
        number_in_instrument: $scope.instrumentQuestions.length + 1
      })

  $scope.nextFromSet = () ->
    angular.forEach $scope.questions, (question, index) ->
      if question.checked
        iQuestion = new InstrumentQuestion()
        iQuestion.instrument_id = $scope.instrument_id
        iQuestion.question_id = question.id
        iQuestion.project_id = $scope.project_id
        iQuestion.number_in_instrument = $scope.instrumentQuestions.length + 1
        iQuestion.$save({},
          (data, headers) ->
            $scope.instrumentQuestions.push(data)
            $scope.showFromSet = false
          (result, headers) ->
        )

  $scope.deleteInstrumentQuestion = (iq) ->
    iq.project_id = $scope.project_id
    iq.$delete({},
      (data, headers) ->
        $scope.instrumentQuestions.splice($scope.instrumentQuestions.indexOf(iq), 1)
      (result, headers) ->
    )

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
