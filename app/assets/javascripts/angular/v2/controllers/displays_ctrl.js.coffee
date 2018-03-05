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

App.controller 'ShowDisplayCtrl', ['$scope', '$stateParams', 'Display', 'Instrument', 'Setting',
 '$state', ($scope, $stateParams, Display, Instrument, Setting, $state) ->
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id
  $scope.showCopy = false

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
  })

  $scope.copyQuestions = () ->
    $scope.showCopy = !$scope.showCopy

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

]
