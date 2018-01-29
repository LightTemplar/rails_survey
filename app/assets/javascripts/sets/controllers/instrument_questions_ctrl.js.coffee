App.controller 'InstrumentQuestionsCtrl', ['$scope', '$routeParams', '$location',
'$route', 'InstrumentQuestion', 'InstrumentQuestions', 'QuestionSet', 'Question',
'Setting', 'Display', 'currentDisplay', '$window', ($scope, $routeParams, $location,
$route, InstrumentQuestion, InstrumentQuestions, QuestionSet, Question, Setting,
Display, currentDisplay, $window) ->

  $scope.project_id = $routeParams.project_id
  $scope.instrument_id = $routeParams.instrument_id
  $scope.showNewView = false
  $scope.showFromSet = false
  $scope.showNewQuestion = false
  $scope.questions = []
  $scope.question_origins = ['New Question', 'Question From Set', 'Multiple Questions From Set']

  # $scope.display = new Display()
  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  }, -> InstrumentQuestions.questions = $scope.instrumentQuestions )

  # $scope.sortableInstrumentQuestions = {
  #   cursor: 'move',
  #   handle: '.moveInstrumentQuestion',
  #   axis: 'y',
  #   stop: (e, ui) ->
  #     angular.forEach $scope.instrumentQuestions, (instrumentQuestion, index) ->
  #       instrumentQuestion.number_in_instrument = index + 1
  #       instrumentQuestion.project_id = $scope.project_id
  #       instrumentQuestion.instrument_id = $scope.instrument_id
  #       instrumentQuestion.$update({})
  # }

  $scope.questionSets = QuestionSet.query({})
  $scope.settings = Setting.get({})
  $scope.displays = Display.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.sortableDisplays = {
    cursor: 'move',
    handle: '.moveDisplay',
    axis: 'y',
    stop: (e, ui) ->
      questionCount = 1
      angular.forEach $scope.displays, (display, index) ->
        display.position = index + 1
        display.project_id = $scope.project_id
        display.instrument_id = $scope.instrument_id
        display.$update({})
        # TODO Inefficient
        angular.forEach $scope.displayQuestions(display), (iq, counter) ->
          iq.number_in_instrument = questionCount
          questionCount += 1
          iq.project_id = $scope.project_id
          iq.instrument_id = $scope.instrument_id
          iq.$update({})
  }

  $scope.validateMode = (display) ->
    $scope.showSaveDisplay = true
    if display.mode == 'SINGLE' && $scope.displayQuestions(display).length > 1
      $window.alert("The display mode is SINGLE but there is more than one
      question on this display. Please delete the extra question(s) and save
      the display.")
    else if display.mode == 'TABLE' && $scope.displayQuestions(display).length > 1 &&
    _.pluck($scope.displayQuestions(display), 'option_set_id').length > 1
      $window.alert("The questions in this TABLE display do not have the same option set!
      Please delete the questions that don't belong to it.")

  $scope.displayQuestions = (display) ->
    _.where($scope.instrumentQuestions, {display_id: display.id})

  $scope.newQuestion = (display) ->
    $scope.showNewQuestion = true
    $scope.display = new Display()
    $scope.display.title = ''
    $scope.display.question_origin = ''
    $scope.display.project_id = $scope.project_id
    $scope.display.instrument_id = $scope.instrument_id
    $scope.display.position = $scope.displays.length + 1

  $scope.showDisplay = (display) ->
    if $scope.currentDisplay == display
      $scope.currentDisplay = null
    else
      $scope.currentDisplay = display

  $scope.addQuestionToDisplay = (display) ->
    $scope.showNewQuestion = true
    $scope.display = display

  # $scope.removeInstrumentQuestion = (iq) ->
  #   if confirm('Are you sure you want to delete this question from the instrument?')
  #     if iq.id
  #       iq.project_id = $scope.project_id
  #       iq.instrument_id = $scope.instrument_id
  #       iq.$delete({} ,
  #         (data, headers) ->
  #           $scope.instrumentQuestions.splice($scope.instrumentQuestions.indexOf(iq), 1)
  #         (result, headers) ->
  #       )

  $scope.saveDisplay = (display) ->
    display.project_id = $scope.project_id
    display.instrument_id = $scope.instrument_id
    if display.id
      display.$update({})
    else
      display.$save({},
        (data, headers) ->
          $scope.display.id = data.id
          $scope.displays.push(data)
        (result, headers) ->
      )
    $scope.showSaveDisplay = false

  $scope.edit = (display) ->
    currentDisplay.display = display
    $location.path '/projects/' + $scope.project_id + '/instruments/' +
    $scope.instrument_id + '/displays/' + display.id

  $scope.delete = (display) ->
    if confirm('Are you sure you want to delete this display group?')
      if display.id
        display.project_id = $scope.project_id
        display.instrument_id = $scope.instrument_id
        display.$delete({} ,
          (data, headers) ->
            $scope.displays.splice($scope.displays.indexOf(display), 1)
          (result, headers) ->
        )

  $scope.getQuestions = (questionSetId) ->
    $scope.questions = Question.query({ "question_set_id": questionSetId })

  $scope.next = (questionSetId) ->
    if (questionSetId == undefined || questionSetId == "-1")
      questionSet = new QuestionSet()
      questionSet.title = new Date().getTime().toString()
      questionSet.$save({},
        (data, headers) ->
          $location.path('/question_sets/' + data.id).search({
            instrument_id: $scope.instrument_id,
            project_id: $scope.project_id,
            number_in_instrument: $scope.instrumentQuestions.length + 1,
            display_id: $scope.display.id,
            multiple: $scope.display.mode != 'SINGLE'
          })
        (result, headers) ->
      )
    else
      $location.path('/question_sets/' + questionSetId).search({
        instrument_id: $scope.instrument_id,
        project_id: $scope.project_id,
        number_in_instrument: $scope.instrumentQuestions.length + 1,
        display_id: $scope.display.id,
        multiple: $scope.display.mode != 'SINGLE'
      })

  $scope.nextQS = (id) ->
    $scope.showQuestionSelectionFromQS = true
    $scope.questionSetQuestions = Question.query({"question_set_id": id})
    $scope.instrumentQuestion = new InstrumentQuestion()
    $scope.instrumentQuestion.instrument_id = $scope.instrument_id
    $scope.instrumentQuestion.project_id = $scope.project_id
    $scope.instrumentQuestion.number_in_instrument = $scope.instrumentQuestions.length + 1
    $scope.instrumentQuestion.display_id = $scope.display.id

  $scope.saveIQ = (instrumentQuestion) ->
    instrumentQuestion.$save({},
      (data, headers) ->
        $route.reload()
      (result, headers) ->
    )

  $scope.nextQuestions = (id) ->
    $scope.showQuestionSelectionFromQS = true
    $scope.questionSetQuestions = Question.query({"question_set_id": id})

  $scope.saveIQs = () ->
    selectedQuestions = _.where($scope.questionSetQuestions, {selected: true})
    responseCount = 0
    previousQuestionCount = $scope.instrumentQuestions.length
    angular.forEach $scope.questionSetQuestions, (q, i) ->
      if q.selected
        iq = new InstrumentQuestion()
        iq.instrument_id = $scope.instrument_id
        iq.project_id = $scope.project_id
        iq.number_in_instrument = previousQuestionCount + 1
        iq.display_id = $scope.display.id
        iq.question_id = q.id
        iq.$save({},
          (data, headers) ->
            responseCount += 1
            if responseCount ==  selectedQuestions.length
              $route.reload()
          (result, headers) ->
        )
        previousQuestionCount += 1

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
