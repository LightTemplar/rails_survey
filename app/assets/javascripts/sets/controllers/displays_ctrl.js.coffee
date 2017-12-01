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
  $scope.sortableDisplays = {
    cursor: 'move',
    handle: '.moveDisplay',
    axis: 'y',
    stop: (e, ui) ->
      angular.forEach $scope.displays, (display, index) ->
        display.position = index + 1
        display.project_id = $scope.project_id
        display.instrument_id = $scope.instrument_id
        display.$update({})
  }

  $scope.newDisplay = () ->
    display = new Display()
    display.project_id = $scope.project_id
    display.instrument_id = $scope.instrument_id
    display.position = $scope.displays.length + 1
    display.$save({},
      (data, headers) ->
        $scope.displays.push(data)
        $scope.edit(data)
      (result, headers) ->
    )

]

App.controller 'ShowDisplayCtrl', ['$scope', '$routeParams', 'currentDisplay',
'Setting', 'InstrumentQuestion',
($scope, $routeParams, currentDisplay, Setting, InstrumentQuestion) ->
  $scope.project_id = $routeParams.project_id
  $scope.instrument_id = $routeParams.instrument_id
  $scope.display = currentDisplay.display
  $scope.settings = Setting.get({})
  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.save = (display) ->
    display.project_id = $scope.project_id
    display.instrument_id = $scope.instrument_id
    display.$update({} ,
      (data, headers) ->
      (result, headers) ->
    )
    angular.forEach $scope.instrumentQuestions, (q, index) ->
      if q.display_id == true
        q.project_id = $scope.project_id
        q.display_id = display.id
        q.$update({} ,
          (data, headers) ->
          (result, headers) ->
        )

]
