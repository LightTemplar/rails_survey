App.controller 'DisplaysCtrl', ['$scope', '$routeParams', '$location', 'Display', 'currentDisplay',
($scope, $routeParams, $location, Display, currentDisplay) ->
  $scope.project_id = $routeParams.project_id
  $scope.instrument_id = $routeParams.instrument_id

  $scope.displays = Display.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.edit = (display) ->
    currentDisplay.display = display
    $location.path '/projects/' + $scope.project_id + '/instruments/' +
    $scope.instrument_id + '/displays/' + display.id

]

App.controller 'ShowDisplayCtrl', ['$scope', '$routeParams', 'currentDisplay',
'Setting', 'InstrumentQuestion',
($scope, $routeParams, currentDisplay, Setting, InstrumentQuestion) ->
  $scope.project_id = $routeParams.project_id
  $scope.instrument_id = $routeParams.instrument_id
  $scope.display = currentDisplay.display
  $scope.settings = Setting.get({})
  console.log($scope.display)
  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

]
