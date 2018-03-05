App.controller 'ShowInstrumentCtrl', ['$scope', '$stateParams', 'Instrument', 'Project', 'Setting',
'$state', 'Display', 'InstrumentQuestion', ($scope, $stateParams, Instrument, Project, Setting,
$state, Display, InstrumentQuestion) ->
  $scope.projects = Project.query({})
  $scope.project_id = $stateParams.project_id
  $scope.id = $stateParams.id
  $scope.settings = Setting.get({}, ->
    $scope.displayTypes = $scope.settings.copy_display_types
  )
  $scope.displays = Display.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.id
  })
  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.id
  })
  $scope.showCopy = false
  $scope.showReOrder = false
  $scope.numRows = 1

  $scope.copyInstrument = () ->
    $scope.showCopy = !$scope.showCopy
    $scope.showReOrder = false
    $scope.instrument = new Instrument()
    $scope.instrument.id = $scope.id
    $scope.instrument.project_id = $scope.project_id

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

  $scope.displayQuestions = (display) ->
    _.sortBy(_.where($scope.instrumentQuestions, {display_id: display.id}), 'number_in_instrument')

  $scope.reOrderQuestions = () ->
    $scope.showReOrder = !$scope.showReOrder
    $scope.showCopy = false
    $scope.instrument = new Instrument()
    $scope.instrument.id = $scope.id
    $scope.instrument.project_id = $scope.project_id
    $scope.instrument.order = ""
    $scope.numRows = $scope.displays.length + $scope.instrumentQuestions.length
    angular.forEach $scope.displays, (display, index) ->
      $scope.instrument.order += display.id + ': ' + display.title + "\n"
      angular.forEach $scope.displayQuestions(display), (question, counter) ->
        $scope.instrument.order += "\t" + question.identifier + "\n"
      $scope.instrument.order += "\n"

  $scope.saveOrder = () ->
    $scope.instrument.$reorder({ order: $scope.instrument.order },
      (data, headers) ->
        $state.go('instrumentQuestions', { project_id: $scope.project_id, instrument_id: $scope.id })
      (result, headers) ->
        alert(result.data.errors)
    )

]
