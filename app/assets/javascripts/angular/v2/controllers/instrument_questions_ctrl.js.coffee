App.controller 'InstrumentQuestionsCtrl', ['$scope', '$stateParams', '$location',
'$state', 'InstrumentQuestion', 'InstrumentQuestions', 'QuestionSet', 'Question',
'Setting', 'Display', 'currentDisplay', '$window', ($scope, $stateParams, $location,
$state, InstrumentQuestion, InstrumentQuestions, QuestionSet, Question, Setting,
Display, currentDisplay, $window) ->

  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.showNewView = false
  $scope.showFromSet = false
  $scope.showNewQuestion = false
  $scope.questions = []
  $scope.question_origins = ['New Question', 'From Set']
  $scope.selectall = false

  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  }, -> InstrumentQuestions.questions = $scope.instrumentQuestions )

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
      $scope.renumberDisplaysAndQuestions()
  }

  $scope.renumberDisplaysAndQuestions = () ->
    questionCount = 1
    angular.forEach $scope.displays, (display, index) ->
      display.position = index + 1
      display.project_id = $scope.project_id
      display.instrument_id = $scope.instrument_id
      display.$update({})
      currentDisplayQuestions = $scope.displayQuestions(display)
      angular.forEach currentDisplayQuestions, (iq, counter) ->
        if iq.number_in_instrument != questionCount
          iq.number_in_instrument = questionCount
          iq.project_id = $scope.project_id
          iq.instrument_id = $scope.instrument_id
          iq.$update({})
        questionCount = questionCount + 1

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
    _.sortBy(_.where($scope.instrumentQuestions, {display_id: display.id}), 'number_in_instrument')

  $scope.newQuestion = () ->
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
    if confirm('Are you sure you want to delete ' + display.title + '?')
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

  $scope.nextInstrumentQuestion = (id) ->
    $scope.showQuestionSelectionFromQS = true
    $scope.questionSetQuestions = Question.query({"question_set_id": id})
    if $scope.display.mode == 'SINGLE'
      $scope.instrumentQuestion = new InstrumentQuestion()
      $scope.instrumentQuestion.instrument_id = $scope.instrument_id
      $scope.instrumentQuestion.project_id = $scope.project_id
      $scope.instrumentQuestion.number_in_instrument = $scope.instrumentQuestions.length + 1
      $scope.instrumentQuestion.display_id = $scope.display.id

  $scope.saveInstrumentQuestions = () ->
    if $scope.display.mode == 'SINGLE'
      $scope.instrumentQuestion.$save({},
        (data, headers) ->
          $state.reload()
        (result, headers) ->
      )
    else
      selectedQuestions = _.where($scope.questionSetQuestions, {selected: true})
      responseCount = 0
      previousQuestion = _.last($scope.displayQuestions($scope.display))
      if previousQuestion
        previousQuestionCount = previousQuestion.number_in_instrument
      else
        previousDisplay = $scope.displays[$scope.display.position - 2]
        if previousDisplay
          lastQuestion = _.last($scope.displayQuestions(previousDisplay))
          previousQuestionCount = lastQuestion.number_in_instrument
        else
          previousQuestionCount = 0
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
              iq.identifier = q.question_identifier
              $scope.instrumentQuestions.push(iq)
              responseCount += 1
              if responseCount ==  selectedQuestions.length
                $scope.showNewQuestion = false
                $scope.currentDisplay = null
                $scope.renumberDisplaysAndQuestions()
            (result, headers) ->
              alert(result.data.errors)
          )
          previousQuestionCount += 1

  $scope.selectAll = () ->
    angular.forEach $scope.questionSetQuestions, (question, index) ->
      if $scope.selectall
        question.selected = true
      else
        question.selected = false

]

App.controller 'ShowInstrumentQuestionCtrl', ['$scope', '$stateParams',
'InstrumentQuestion', 'Setting', 'Option', 'InstrumentQuestions', 'NextQuestion',
'MultipleSkip',
($scope, $stateParams, InstrumentQuestion, Setting, Option, InstrumentQuestions,
NextQuestion, MultipleSkip) ->

  $scope.options = []
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  # TODO: Does not work if browser refreshed
  $scope.instrumentQuestion = _.first(_.filter(InstrumentQuestions.questions,
    (q) -> q.id == parseInt($stateParams.id)))

  if $scope.instrumentQuestion.option_set_id
    nonSpecialOptions = Option.query({
      'option_set_id': $scope.instrumentQuestion.option_set_id
    }, ->
      $scope.options = $scope.options.concat(nonSpecialOptions)
    )

  if $scope.instrumentQuestion.special_option_set_id
    specialOptions = Option.query({
      'option_set_id': $scope.instrumentQuestion.special_option_set_id
    }, ->
      $scope.options = $scope.options.concat(specialOptions)
    )

  $scope.settings = Setting.get({})
  $scope.nextQuestions = NextQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.instrumentQuestion.id
  })

  $scope.multipleSkips = MultipleSkip.query({
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

  $scope.questionTypesWithMultipleSkips = (questionType) ->
    if $scope.settings.question_with_multiple_skips
      questionType in $scope.settings.question_with_multiple_skips

  $scope.addNextQuestion = () ->
    $scope.newNextQuestion = new NextQuestion()
    $scope.newNextQuestion.instrument_question_id = $scope.instrumentQuestion.id
    $scope.newNextQuestion.question_identifier = $scope.instrumentQuestion.identifier
    $scope.newNextQuestion.project_id = $scope.project_id
    $scope.newNextQuestion.instrument_id = $scope.instrument_id
    $scope.nextQuestions.push($scope.newNextQuestion)

  $scope.saveSkip = (nextQuestion) ->
    setRouteParameters(nextQuestion)
    exists = _.where($scope.nextQuestions, {option_identifier: nextQuestion.option_identifier})
    if exists.length > 1
      alert 'Skip for Option is already set!'
    else
      if nextQuestion.id
        nextQuestion.$update({} ,
          (data, headers) ->
            nextQuestion = data
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        nextQuestion.$save({} ,
          (data, headers) ->
            nextQuestion = data
          (result, headers) ->
            alert(result.data.errors)
        )

  $scope.deleteSkip = (nextQuestion) ->
    if confirm('Are you sure you want to delete this skip pattern?')
      setRouteParameters(nextQuestion)
      if nextQuestion.id
        nextQuestion.$delete({} ,
          (data, headers) ->
            $scope.nextQuestions.splice($scope.nextQuestions.indexOf(nextQuestion), 1)
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        $scope.nextQuestions.splice($scope.nextQuestions.indexOf(nextQuestion), 1)

  $scope.deleteMultiSkip = (multiSkip) ->
    if confirm('Are you sure you want to delete this skip?')
      setRouteParameters(multiSkip)
      if multiSkip.id
        multiSkip.$delete({} ,
          (data, headers) ->
            $scope.multipleSkips.splice($scope.multipleSkips.indexOf(multiSkip, 1))
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        $scope.multipleSkips.splice($scope.multipleSkips.indexOf(multiSkip, 1))

  $scope.addMultiSkip = () ->
    skipQuestion = new MultipleSkip()
    skipQuestion.question_identifier = $scope.instrumentQuestion.identifier
    setRouteParameters(skipQuestion)
    $scope.multipleSkips.push(skipQuestion)

  $scope.saveMultiSkip = (multiSkip) ->
    exists = _.where($scope.multipleSkips, {
      option_identifier: multiSkip.option_identifier,
      skip_question_identifier: multiSkip.skip_question_identifier,
      instrument_question_id: multiSkip.instrument_question_id
    })
    if exists.length > 1
      alert 'Skip question for option is already set!'
    else
      setRouteParameters(multiSkip)
      if multiSkip.id
        multiSkip.$update({} ,
          (data, headers) ->
            multiSkip = data
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        multiSkip.$save({} ,
          (data, headers) ->
            multiSkip = data
          (result, headers) ->
            alert(result.data.errors)
        )

  setRouteParameters = (nextQuestion) ->
    nextQuestion.instrument_question_id = $scope.instrumentQuestion.id
    nextQuestion.project_id = $scope.project_id
    nextQuestion.instrument_id = $scope.instrument_id

]
