App.controller 'DisplayCtrl', ['$scope', ($scope) ->
  $scope.displayQuestions = _.where($scope.instrumentQuestions, {display_id: $scope.display.id})
  $scope.sortableInstrumentQuestions = {
    cursor: 'move',
    handle: '.moveInstrumentQuestion',
    axis: 'y',
    stop: (e, ui) ->
      previousDisplay = $scope.displays[$scope.display.position - 2]
      if previousDisplay
        previousInstrumentQuestions = _.where($scope.instrumentQuestions, {display_id: previousDisplay.id})
        lastQuestion = _.max(previousInstrumentQuestions, (q) -> q.number_in_instrument)
        previousQuestionNumber = lastQuestion.number_in_instrument
      else
        previousQuestionNumber = 0
      angular.forEach $scope.displayQuestions, (instrumentQuestion, index) ->
        instrumentQuestion.number_in_instrument = previousQuestionNumber + index + 1
        instrumentQuestion.project_id = $scope.project_id
        instrumentQuestion.instrument_id = $scope.instrument_id
        instrumentQuestion.$update({})
  }

  $scope.updateInstrumentQuestion = (iq) ->
    iq.project_id = $scope.project_id
    iq.$update({},
      (data, headers) ->
      (result, headers) ->
        alert(result.data.errors)
    )

  $scope.removeInstrumentQuestion = (iq) ->
    if confirm('Are you sure you want to delete ' + iq.identifier + ' from the instrument?')
      if iq.id
        iq.project_id = $scope.project_id
        iq.instrument_id = $scope.instrument_id
        iq.$delete({} ,
          (data, headers) ->
            removeInstrumentQuestionFromArrays(iq)
          (result, headers) ->
            alert(result.data.errors)
        )

  removeInstrumentQuestionFromArrays = (iq) ->
    $scope.displayQuestions.splice($scope.displayQuestions.indexOf(iq), 1)
    $scope.instrumentQuestions.splice($scope.instrumentQuestions.indexOf(iq), 1)
    $scope.$parent.renumberDisplaysAndQuestions()

]

App.controller 'ShowDisplayCtrl', ['$scope', '$stateParams', 'Display', 'Instrument',
'Setting', '$state', 'InstrumentQuestion', 'QuestionSet', 'Question', ($scope, $stateParams, Display,
 Instrument, Setting, $state, InstrumentQuestion, QuestionSet, Question) ->
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id
  $scope.showCopy = false
  $scope.showQuestions = true
  $scope.showAddQuestion = false

  $scope.display = Display.get({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'id': $scope.id
  }, ->
    $scope.displayQuestions = $scope.display.instrument_questions
  )
  $scope.settings = Setting.get({}, ->
    $scope.displayTypes = $scope.settings.copy_display_types
    $scope.displayTypes.splice($scope.displayTypes.indexOf('ALL_QUESTIONS_ON_ONE_SCREEN'), 1)
  )
  $scope.instruments = Instrument.query({
    'project_id': $scope.project_id
  }, -> $scope.instrument = _.findWhere($scope.instruments, {id: parseInt($scope.instrument_id)}))
  $scope.questionSets = QuestionSet.query({})
  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.showDisplayQuestions = () ->
    $scope.copyQuestions()

  $scope.copyQuestions = () ->
    $scope.showCopy = !$scope.showCopy
    $scope.showQuestions = !$scope.showQuestions

  $scope.saveCopy = () ->
    $scope.display.project_id = $scope.project_id
    $scope.display.$copy({
      destination_instrument_id: $scope.display.destination_instrument_id,
      display_type: $scope.display.display_type
      },
      (data, headers) ->
        $state.go('project', { id: $scope.project_id })
      (result, headers) ->
        alert(result.data.errors)
    )

  # $scope.sortableInstrumentQuestions = {
  #   cursor: 'move',
  #   handle: '.moveInstrumentQuestion',
  #   axis: 'y',
  #   stop: (e, ui) ->
  #     previousDisplay = $scope.displays[$scope.display.position - 2]
  #     if previousDisplay
  #       previousInstrumentQuestions = _.where($scope.instrumentQuestions, {display_id: previousDisplay.id})
  #       lastQuestion = _.max(previousInstrumentQuestions, (q) -> q.number_in_instrument)
  #       previousQuestionNumber = lastQuestion.number_in_instrument
  #     else
  #       previousQuestionNumber = 0
  #     angular.forEach $scope.displayQuestions, (instrumentQuestion, index) ->
  #       instrumentQuestion.number_in_instrument = previousQuestionNumber + index + 1
  #       instrumentQuestion.project_id = $scope.project_id
  #       instrumentQuestion.instrument_id = $scope.instrument_id
  #       instrumentQuestion.$update({})
  # }

  $scope.updateInstrumentQuestion = (iq) ->
    instrumentQuestion = new InstrumentQuestion()
    instrumentQuestion.id = iq.id
    instrumentQuestion.instrument_id = iq.instrument_id
    instrumentQuestion.identifier = iq.identifier
    instrumentQuestion.project_id = $scope.project_id
    instrumentQuestion.$update({},
      (data, headers) ->
      (result, headers) ->
        alert(result.data.errors)
    )

  $scope.removeInstrumentQuestion = (instrumentQuestion) ->
    if confirm('Are you sure you want to delete ' + instrumentQuestion.identifier + ' from the instrument?')
      iq = new InstrumentQuestion
      iq.id = instrumentQuestion.id
      iq.display_id = $scope.id
      iq.project_id = $scope.project_id
      iq.instrument_id = $scope.instrument_id
      iq.$delete({} ,
        (data, headers) ->
          $state.reload()
        (result, headers) ->
          alert(result.data.errors)
      )

  # removeInstrumentQuestionFromArrays = (iq) ->
  #   $scope.displayQuestions.splice($scope.displayQuestions.indexOf(iq), 1)
  #   $scope.instrumentQuestions.splice($scope.instrumentQuestions.indexOf(iq), 1)
  #   $scope.$parent.renumberDisplaysAndQuestions()

  $scope.validateMode = ->
    $scope.showSaveDisplay = true
    if $scope.display.mode == 'SINGLE' && $scope.displayQuestions.length > 1
      alert("The display mode is SINGLE but there is more than one
      question on this display. Please delete the extra question(s) and save
      the display.")
    else if $scope.display.mode == 'TABLE' && $scope.displayQuestions.length > 0 &&
    _.pluck($scope.displayQuestions, 'option_set_id').length > 1
      alert("The questions in this TABLE display do not have the same option set!
      Please delete the questions that don't belong to it.")

  $scope.saveDisplay = () ->
    $scope.display.project_id = $scope.project_id
    $scope.display.$update({},
        (data, headers) ->
          $scope.display = data
        (result, headers) ->
          alert(result.data.errors)
      )
    $scope.showSaveDisplay = false

  $scope.addQuestionToDisplay = () ->
    $scope.showQuestions = !$scope.showQuestions
    $scope.showAddQuestion = true
    $scope.instrumentQuestion = new InstrumentQuestion()
    $scope.instrumentQuestion.instrument_id = $scope.instrument_id
    $scope.instrumentQuestion.project_id = $scope.project_id

  $scope.getQuestionSetQuestions = () ->
    if $scope.display.question_set_id
      $scope.questionSetQuestions = Question.query({"question_set_id": $scope.display.question_set_id}, ->
        if $scope.display.mode == 'TABLE'
          $scope.questionSetQuestions = _.where($scope.questionSetQuestions, {
            option_set_id: parseInt($scope.displayQuestions[0].option_set_id)
          })
      )

  $scope.saveInstrumentQuestions = () ->
    previousQuestionCount = getQuestionCount()
    if $scope.display.mode == 'SINGLE'
      question = _.findWhere($scope.questionSetQuestions, { id: parseInt($scope.instrumentQuestion.question_id) })
      if question
        $scope.instrumentQuestion.identifier = getInstrumentQuestionIdentifier(question)
        $scope.instrumentQuestion.number_in_instrument = previousQuestionCount + 1
        $scope.instrumentQuestion.display_id = $scope.display.id
        $scope.instrumentQuestion.$save({},
          (data, headers) ->
            $state.reload()
          (result, headers) ->
            alert(result.data.errors)
        )
    else
      selectedQuestions = _.where($scope.questionSetQuestions, {selected: true})
      responseCount = 0
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
              $scope.displayQuestions.push(iq)
              responseCount += 1
              if responseCount ==  selectedQuestions.length
                $state.reload()
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

  getQuestionCount = () ->
    previousQuestion = _.last($scope.displayQuestions)
    if previousQuestion
      previousQuestionCount = previousQuestion.number_in_instrument
    else
      # previousDisplay = $scope.displays[$scope.display.position - 2]
      # if previousDisplay
      #   lastQuestion = _.last($scope.displayQuestions(previousDisplay))
      #   previousQuestionCount = lastQuestion.number_in_instrument
      # else
        previousQuestionCount = 0
    previousQuestionCount

  $scope.selectAll = () ->
    angular.forEach $scope.questionSetQuestions, (question, index) ->
      if $scope.selectall
        question.selected = true
      else
        question.selected = false

]
