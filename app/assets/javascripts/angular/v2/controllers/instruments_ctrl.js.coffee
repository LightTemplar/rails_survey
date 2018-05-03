App.controller 'ShowInstrumentCtrl', ['$scope', '$stateParams', 'Instrument',
($scope, $stateParams, Instrument) ->

  instrument_id = if $stateParams.instrument_id then $stateParams.instrument_id else $stateParams.id
  $scope.instrument = Instrument.get({
    'project_id': $stateParams.project_id,
    'id': instrument_id
  })

]

App.controller 'ReorderInstrumentQuestionsCtrl', ['$scope', '$stateParams',
'Instrument', '$state', 'Display',
($scope, $stateParams, Instrument, $state, Display) ->
  $scope.project_id = $stateParams.project_id
  $scope.id = $stateParams.id
  $scope.numRows = 1

  reOrderQuestions = () ->
    angular.forEach $scope.displays, (display, ind) ->
      $scope.numRows = $scope.numRows + 1 + display.instrument_questions.length
    angular.forEach $scope.displays, (display, index) ->
      $scope.instrument.order += display.id + ': ' + display.title + "\n"
      angular.forEach display.instrument_questions, (question, counter) ->
        $scope.instrument.order += "\t" + question.identifier + "\n"
      $scope.instrument.order += "\n"

  $scope.instrument = Instrument.get({
    'project_id': $scope.project_id,
    'id': $scope.id
  }, ->
    $scope.instrument.order = ""
  )

  $scope.displays = Display.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.id
  }, ->
    reOrderQuestions()
  )

  $scope.saveOrder = () ->
    $scope.instrument.$reorder({},
      (data, headers) ->
        $state.go('instrumentQuestions', { project_id: $scope.project_id, instrument_id: $scope.id })
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'CopyInstrumentCtrl', ['$scope', '$stateParams', 'Instrument', '$state',
'Project', 'Setting', ($scope, $stateParams, Instrument, $state, Project, Setting) ->
  $scope.projects = Project.query({})
  $scope.settings = Setting.get({}, ->
    $scope.displayTypes = $scope.settings.copy_display_types
  )

  $scope.instrument = Instrument.get({
    'project_id': $stateParams.project_id,
    'id': $stateParams.id
  })

  $scope.saveCopy = () ->
    $scope.instrument.$copy({
      destination_project_id: $scope.instrument.destination_project_id,
      display_type: $scope.instrument.display_type
      },
      (data, headers) ->
        $state.go('project', {id: data.project_id})
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'InstrumentSkipPatternsCtrl', ['$scope', '$stateParams', 'Instrument',
'InstrumentNextQuestion', '$state', ($scope, $stateParams, Instrument, InstrumentNextQuestion, $state) ->

  $scope.instrument = Instrument.get({
    'project_id': $stateParams.project_id,
    'id': $stateParams.id
  })

  $scope.nextQuestions = InstrumentNextQuestion.query({
    'project_id': $stateParams.project_id,
    'instrument_id': $stateParams.id
  })

  $scope.importSkipPatterns = () ->
    $scope.instrument.$importSkipPatterns({},
      (data, headers) ->
        $state.reload()
      (result, headers) ->
        alert(result.data.errors)
    )

]
