App.controller 'PDFCtrl', ['$scope', '$stateParams', 'Instrument', 'Setting', '$state',
($scope, $stateParams, Instrument, Setting, $state) ->

  $scope.instrument_id = if $stateParams.instrument_id then $stateParams.instrument_id else $stateParams.id
  $scope.project_id = $stateParams.project_id

  $scope.instrument = Instrument.get({
    'project_id': $scope.project_id,
    'id': $scope.instrument_id
  })

  $scope.settings = Setting.get({}, ->
    $scope.languages = $scope.settings.languages
  )

]
