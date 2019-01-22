App.controller 'DisplaysCtrl', ['$scope', '$stateParams', '$state', 'Display', 'Instrument',
($scope, $stateParams, $state, Display, Instrument) ->

  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id

  $scope.instrument = Instrument.get({
    'project_id': $scope.project_id,
    'id': $scope.instrument_id
  })

  $scope.displays = Display.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.sortableDisplays = {
    cursor: 'move',
    handle: '.moveDisplay',
    axis: 'y',
    stop: (e, ui) ->
      order = []
      angular.forEach $scope.displays, (display, index) ->
        order.push(display.id)
      $scope.instrument.display_ids = order
      $scope.instrument.$reorderDisplays({},
        (data, headers) ->
          $state.reload()
        (result, headers) ->
          alert(result.data.errors)
      )
  }

  $scope.delete = (display) ->
    if confirm('Are you sure you want to delete ' + display.title + '?')
      if display.id
        display.project_id = $scope.project_id
        display.instrument_id = $scope.instrument_id
        display.$delete({},
          (data, headers) ->
            $scope.displays.splice($scope.displays.indexOf(display), 1)
          (result, headers) ->
        )

]

App.controller 'NewDisplayCtrl', ['$scope', '$stateParams', '$state', 'Instrument',
'Setting', 'Display', 'Section', ($scope, $stateParams, $state, Instrument,
Setting, Display, Section) ->
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id

  $scope.instrument = Instrument.get({
    'project_id': $scope.project_id,
    'id': $scope.instrument_id
  }, ->
    $scope.display = new Display()
    $scope.display.project_id = $scope.project_id
    $scope.display.instrument_id = $scope.instrument_id
    $scope.display.position = $scope.instrument.display_count + 1
  )

  $scope.settings = Setting.get({})
  $scope.sections = Section.query({
    'project_id': $scope.project_id
    'instrument_id': $scope.instrument_id
  })

  $scope.saveDisplay = () ->
    $scope.display.$save({},
      (data, headers) ->
        $state.go('display', {
          project_id: $scope.project_id,
          instrument_id: $scope.instrument_id,
          id: data.id
        })
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'ShowDisplayCtrl', ['$scope', '$stateParams', 'Display', 'DisplayInstruction',
'Instrument', 'Setting', '$state', 'InstrumentQuestion', 'QuestionSet', 'Question', 'Instruction',
'Section', ($scope, $stateParams, Display, DisplayInstruction, Instrument, Setting, $state,
InstrumentQuestion, QuestionSet, Question, Instruction, Section) ->
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id
  $scope.showQuestions = true
  $scope.showCopy = false
  $scope.showAddQuestion = false
  $scope.showMove = false
  $scope.showInstructions = false
  $scope.showTables = false

  $scope.sections = Section.query({
    'project_id': $scope.project_id
    'instrument_id': $scope.instrument_id
  })

  $scope.display = Display.get({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'id': $scope.id
  })
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
  }, ->
    $scope.displayQuestions = _.where($scope.instrumentQuestions, {display_id: $scope.display.id})
    $scope.tableIdentifiers = _.compact(_.uniq(_.map($scope.displayQuestions, (iq) -> iq.table_identifier)))
  )
  $scope.displayInstructions = DisplayInstruction.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'display_id': $scope.id
  })
  $scope.instructions = Instruction.query({})
  $scope.displays = Display.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.toggleViews = (q, c, m, i, t) ->
    $scope.showQuestions = q
    $scope.showCopy = c
    $scope.showMove = m
    $scope.showInstructions = i
    $scope.showTables = t

  $scope.previous = (display) ->
    if display.position != 1
      previousDisplay = _.findWhere($scope.displays, {position: display.position - 1})
      $state.go('display',
      { project_id: $scope.project_id, instrument_id: $scope.instrument_id,
      id: previousDisplay.id
      })

  $scope.next = (display) ->
    last = _.last($scope.displays)
    if (display.position != _.last($scope.displays).position)
      nextDisplay = _.findWhere($scope.displays, {position: display.position + 1})
      $state.go('display',
      {project_id: $scope.project_id, instrument_id: $scope.instrument_id,
      id: nextDisplay.id
      })

  $scope.tableQuestions = (identifier) ->
    _.where($scope.displayQuestions, {table_identifier: identifier})

  $scope.addQuestionsToTable = (identifier) ->
    angular.forEach $scope.displayQuestions, (dq, index) ->
      dq.selected = null
    $scope.editIdentifier = identifier

  $scope.questionInTable = (question, identifier) ->
    $scope.tableQuestions(identifier).indexOf(question) > -1

  $scope.addAbleDisplayQuestions = (identifier) ->
    if $scope.tableQuestions(identifier).length == 0
      _.filter($scope.displayQuestions, (qst) ->
        qst.table_identifier == null
      )
    else
      _.filter($scope.displayQuestions, (qst) ->
        qst.option_set_id == $scope.tableQuestions(identifier)[0].option_set_id &&
        qst.table_identifier != $scope.tableQuestions(identifier)[0].table_identifier
      )

  $scope.saveToTable = (identifier) ->
    angular.forEach $scope.displayQuestions, (dq, index) ->
      if dq.selected
        dq.table_identifier = identifier
        dq.project_id = $scope.project_id
        dq.$update({},
          (data, headers) ->
          (result, headers) ->
            alert(result.data.errors)
        )
    $scope.editIdentifier = null

  $scope.removeQuestionFromTable = (question) ->
    question.table_identifier = null
    question.project_id = $scope.project_id
    if question.id
      question.$update({},
        (data, headers) ->
          (result, headers) ->
            alert(result.data.errors)
      )

  $scope.createTable = () ->
    $scope.showNewTable = true
    $scope.newTable = {name: ''}

  $scope.saveNewTable = () ->
    $scope.showNewTable = false
    $scope.tableIdentifiers.push($scope.newTable.name)

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

  $scope.saveMovedQuestions = () ->
    $scope.display.project_id = $scope.project_id
    $scope.display.moved = []
    angular.forEach $scope.displayQuestions, (qst, index) ->
      if qst.selected
        $scope.display.moved.push(qst.id)
    $scope.display.$move({},
      (data, headers) ->
        $state.go('display', { project_id: $scope.project_id,
        instrument_id: $scope.instrument_id, id: data.id })
      (result, headers) ->
        alert(result.data.errors)
    )

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

  $scope.saveDisplay = () ->
    $scope.display.project_id = $scope.project_id
    $scope.display.$update({},
        (data, headers) ->
          $scope.display = data
        (result, headers) ->
          alert(result.data.errors)
      )

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
        previousQuestionCount = $scope.display.last_question_number_in_previous_display
    previousQuestionCount

  $scope.selectAll = () ->
    angular.forEach $scope.questionSetQuestions, (question, index) ->
      if $scope.selectall
        question.selected = true
      else
        question.selected = false

  $scope.saveDisplayInstruction = (displayInstruction) ->
    displayInstruction.instrument_id = $scope.instrument_id
    displayInstruction.project_id = $scope.project_id
    if displayInstruction.id
      displayInstruction.$update({},
        (data, headers) ->
          displayInstruction = data
        (result, headers) ->
          alert(result.data.errors)
      )
    else
      displayInstruction.$save({},
        (data, headers) ->
          displayInstruction = data
        (result, headers) ->
          alert(result.data.errors)
      )

  $scope.deleteDisplayInstruction = (displayInstruction) ->
    displayInstruction.instrument_id = $scope.instrument_id
    displayInstruction.project_id = $scope.project_id
    index = $scope.displayInstructions.indexOf(displayInstruction)
    if displayInstruction.id
      displayInstruction.$delete({},
        (data, headers) ->
          $scope.displayInstructions.splice(index, 1)
        (result, headers) ->
          alert(result.data.errors)
      )
    else
      $scope.displayInstructions.splice(index, 1)

  $scope.addDisplayInstruction = () ->
    displayInstruction = new DisplayInstruction()
    displayInstruction.display_id = $scope.display.id
    displayInstruction.instruction_id = ''
    $scope.displayInstructions.push(displayInstruction)

  startNumber = 1
  $scope.sortableInstrumentQuestions = {
    cursor: 'move',
    handle: '.moveInstrumentQuestion',
    axis: 'y',
    start: () ->
      startNumber = $scope.displayQuestions[0].number_in_instrument
    stop: (e, ui) ->
      angular.forEach $scope.displayQuestions, (question, index) ->
        question.number_in_instrument = startNumber + index
        question.project_id = $scope.project_id
        question.$update({},
          (data, headers) ->
          (result, headers) ->
            alert(result.data.errors)
        )
  }

]
