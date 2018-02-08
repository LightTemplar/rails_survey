App.controller 'DisplaysCtrl', ['$scope', '$stateParams', '$location', 'Display', 'currentDisplay',
($scope, $stateParams, $location, Display, currentDisplay) ->
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id

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

App.controller 'ShowDisplayCtrl', ['$scope', '$stateParams', 'currentDisplay',
'Setting', 'InstrumentQuestion', '$location',
($scope, $stateParams, currentDisplay, Setting, InstrumentQuestion, $location) ->
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
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
      q.project_id = $scope.project_id
      if q.display_id == true
        q.display_id = display.id
      q.$update({} ,
        (data, headers) ->
          $location.path '/projects/' + $scope.project_id + '/instruments/' +
          $scope.instrument_id + '/displays'
        (result, headers) ->
      )

  $scope.optionSelected = (iq) ->
    angular.forEach $scope.instrumentQuestions, (q, index) ->
      if q.display_id == iq.display_id && iq != q
        q.display_id = null

  $scope.checkOptionSetId = (display, instrumentQuestion) ->
    instrumentQuestion.display_id = display.id
    sameDisplay = _.where($scope.instrumentQuestions, {display_id: display.id})
    angular.forEach sameDisplay, (iQuestion, index) ->
      if iQuestion.type != instrumentQuestion.type || iQuestion.option_set_id != instrumentQuestion.option_set_id
        alert("Questions in the same table display need to have the same option set")
        instrumentQuestion.checked = false
        instrumentQuestion.display_id = null
      else
        instrumentQuestion.display_id = true

]

App.controller 'DisplayCtrl', ['$scope', ($scope) ->
  $scope.displayQuestions = _.where($scope.instrumentQuestions, {display_id: $scope.display.id})

  $scope.sortableInstrumentQuestions = {
    cursor: 'move',
    handle: '.moveInstrumentQuestion',
    axis: 'y',
    stop: (e, ui) ->
      previousDisplay = $scope.displays[$scope.display.position - 2]
      lastQuestion = _.max(previousDisplay.instrument_questions, (q) -> q.number_in_instrument)
      angular.forEach $scope.displayQuestions, (instrumentQuestion, index) ->
        instrumentQuestion.number_in_instrument = lastQuestion.number_in_instrument + index + 1
        instrumentQuestion.project_id = $scope.project_id
        instrumentQuestion.instrument_id = $scope.instrument_id
        instrumentQuestion.$update({})
  }

  $scope.removeInstrumentQuestion = (iq) ->
    if confirm('Are you sure you want to delete this question from the instrument?')
      if iq.id
        iq.project_id = $scope.project_id
        iq.instrument_id = $scope.instrument_id
        iq.$delete({} ,
          (data, headers) ->
            $scope.displayQuestions.splice($scope.displayQuestions.indexOf(iq), 1)
          (result, headers) ->
        )

]
