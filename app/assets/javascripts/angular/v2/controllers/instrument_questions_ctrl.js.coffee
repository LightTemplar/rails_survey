App.controller 'InstrumentQuestionsCtrl', ['$scope', '$stateParams', '$location',
'$state', 'InstrumentQuestion', 'InstrumentQuestions', 'QuestionSet', 'Question',
'Setting', 'Display', 'currentDisplay', 'Instrument', ($scope, $stateParams, $location,
$state, InstrumentQuestion, InstrumentQuestions, QuestionSet, Question, Setting,
Display, currentDisplay, Instrument) ->

  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.showNewView = false
  $scope.showFromSet = false
  $scope.showNewDisplay = false
  $scope.questions = []
  $scope.question_origins = ['New Question', 'From Set']
  $scope.selectall = false
  $scope.instrumentQuestions = []

  $scope.instrument = Instrument.get({
    'project_id': $scope.project_id,
    'id': $scope.instrument_id
  })

  $scope.questionSets = QuestionSet.query({})
  $scope.settings = Setting.get({})
  $scope.displays = Display.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  }, ->
    angular.forEach $scope.displays, (display, index) ->
      angular.forEach display.instrument_questions, (iq, ind) ->
        $scope.instrumentQuestions.push(iq)
  )

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
      currentDisplayQuestions = display.instrument_questions
      angular.forEach currentDisplayQuestions, (iq, counter) ->
        if iq.number_in_instrument != questionCount
          iq.number_in_instrument = questionCount
          iq.project_id = $scope.project_id
          iq.instrument_id = $scope.instrument_id
          iq.$update({})
        questionCount = questionCount + 1

  $scope.validateMode = (display) ->
    $scope.showSaveDisplay = true
    if display.mode == 'SINGLE' && display.instrument_questions.length > 1
      alert("The display mode is SINGLE but there is more than one
      question on this display. Please delete the extra question(s) and save
      the display.")
    else if display.mode == 'TABLE' && display.instrument_questions.length > 1 &&
    _.pluck(display.instrument_questions, 'option_set_id').length > 1
      alert("The questions in this TABLE display do not have the same option set!
      Please delete the questions that don't belong to it.")

  $scope.newDisplay = () ->
    $scope.showNewDisplay = true
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
    $scope.showNewDisplay = true
    $scope.display = display

  $scope.saveDisplay = (display) ->
    display.project_id = $scope.project_id
    display.instrument_id = $scope.instrument_id
    if display.id
      display.$update({})
    else
      display.$save({},
        (data, headers) ->
          $scope.displays.push(data)
          $state.go('display', { project_id: $scope.project_id,
          instrument_id: $scope.instrument_id,
          id: data.id
          })
        (result, headers) ->
          alert(result.data.errors)
      )

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
      question = _.findWhere($scope.questionSetQuestions, { id: parseInt($scope.instrumentQuestion.question_id) })
      if question
        $scope.instrumentQuestion.identifier = getInstrumentQuestionIdentifier(question)
        $scope.instrumentQuestion.$save({},
          (data, headers) ->
            $scope.instrumentQuestions.push(data)
            $scope.showNewDisplay = false
            $scope.currentDisplay = null
            $scope.renumberDisplaysAndQuestions()
          (result, headers) ->
            alert(result.data.errors)
        )
    else
      selectedQuestions = _.where($scope.questionSetQuestions, {selected: true})
      responseCount = 0
      previousQuestion = _.last($scope.display.instrument_questions)
      if previousQuestion
        previousQuestionCount = previousQuestion.number_in_instrument
      else
        previousDisplay = $scope.displays[$scope.display.position - 2]
        if previousDisplay
          lastQuestion = _.last(previousDisplay.instrument_questions)
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
          iq.identifier = getInstrumentQuestionIdentifier(q)
          iq.$save({},
            (data, headers) ->
              $scope.instrumentQuestions.push(iq)
              responseCount += 1
              if responseCount ==  selectedQuestions.length
                $scope.showNewDisplay = false
                $scope.currentDisplay = null
                $scope.renumberDisplaysAndQuestions()
            (result, headers) ->
              alert(result.data.errors)
          )
          previousQuestionCount += 1

  getInstrumentQuestionIdentifier = (question) ->
    iq = _.findWhere($scope.instrumentQuestions, { identifier: question.question_identifier})
    if iq
      question.question_identifier + '_' + new Date().getTime().toString(36).split('').reverse().join('')
    else
      question.question_identifier

  $scope.selectAll = () ->
    angular.forEach $scope.questionSetQuestions, (question, index) ->
      if $scope.selectall
        question.selected = true
      else
        question.selected = false

]

App.controller 'ShowInstrumentQuestionCtrl', ['$scope', '$stateParams',
'InstrumentQuestion', 'Setting', 'Option', 'InstrumentQuestions', 'NextQuestion',
'MultipleSkip', 'FollowUpQuestion', 'Question',
($scope, $stateParams, InstrumentQuestion, Setting, Option, InstrumentQuestions,
NextQuestion, MultipleSkip, FollowUpQuestion, Question) ->

  $scope.options = []
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id

  $scope.instrumentQuestion = InstrumentQuestion.get({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'id': $scope.id
  }, ->
    if $scope.instrumentQuestion.option_set_id
      regularOptions = Option.query({'option_set_id': $scope.instrumentQuestion.option_set_id}, ->
        angular.forEach regularOptions, (option, index) ->
          $scope.options.push(option)
      )
    if $scope.instrumentQuestion.special_option_set_id
      specialOptions = Option.query({'option_set_id': $scope.instrumentQuestion.special_option_set_id}, ->
        angular.forEach specialOptions, (option, index) ->
          $scope.options.push(option)
      )
  )

  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.settings = Setting.get({})
  $scope.nextQuestions = NextQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })

  $scope.multipleSkips = MultipleSkip.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })

  $scope.followingUpQuestions = FollowUpQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })

  $scope.questionTypesWithSkipPatterns = (questionType) ->
    if $scope.settings.question_with_skips
      questionType in $scope.settings.question_with_skips

  $scope.questionsAfter = (question) ->
    questions = _.sortBy($scope.instrumentQuestions, 'number_in_instrument')
    questions.slice(question.number_in_instrument, questions.length)

  $scope.questionsBefore = (question) ->
    $scope.instrumentQuestions.slice(0, (question.number_in_instrument - 1))

  $scope.questionTypesWithMultipleSkips = (questionType) ->
    if $scope.settings.question_with_multiple_skips
      questionType in $scope.settings.question_with_multiple_skips

  $scope.followUpQuestions = (question) ->
    questions = []
    if $scope.settings.question_types_with_follow_ups
      angular.forEach $scope.questionsBefore(question), (q, i) ->
        if q.type in $scope.settings.question_types_with_follow_ups
          questions.push(q)
    questions

  $scope.addFollowUp = () ->
    followup = new FollowUpQuestion()
    followup.position = $scope.followingUpQuestions.length
    followup.instrument_question_id = $scope.instrumentQuestion.id
    followup.question_identifier = $scope.instrumentQuestion.identifier
    $scope.followingUpQuestions.push(followup)

  $scope.saveFollowUps = () ->
    count = 0
    index = $scope.instrumentQuestion.text.indexOf("[followup]")
    while (index > -1)
      ++count
      index = $scope.instrumentQuestion.text.indexOf("[followup]", ++index)
    if count == $scope.followingUpQuestions.length
      $scope.instrumentQuestion.project_id = $scope.project_id
      question = new Question()
      question.id = $scope.instrumentQuestion.question_id
      question.question_set_id = $scope.instrumentQuestion.question_set_id
      question.text = $scope.instrumentQuestion.text
      question.$update({},
        (data, headers) ->
        (result, headers) ->
          alert(result.data.errors)
      )
      angular.forEach $scope.followingUpQuestions, (followup, index) ->
        followup.project_id = $scope.project_id
        followup.instrument_id = $scope.instrument_id
        if followup.id
          followup.$update({} ,
            (data, headers) ->
            (result, headers) ->
              alert(result.data.errors)
          )
        else
          followup.$save({},
            (data, headers) ->
            (result, headers) ->
              alert(result.data.errors)
          )
    else
      alert('You need to insert the right number of "[followup]" in the question text')

  $scope.deleteFollowUp = (followup) ->
    followup.project_id = $scope.project_id
    followup.instrument_id = $scope.instrument_id
    if confirm('Are you sure you want to delete this followup?')
      if followup.id
        followup.$delete({},
          (data, headers) ->
            $scope.followingUpQuestions.splice($scope.followingUpQuestions.indexOf(followup), 1)
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        $scope.followingUpQuestions.splice($scope.followingUpQuestions.indexOf(followup), 1)

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
