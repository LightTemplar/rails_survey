App.controller 'InstrumentsCtrl', ['$scope', 'Instrument', ($scope, Instrument) ->
  $scope.initialize = (project_id) ->
    $scope.instruments = Instrument.query({"project_id": project_id} )
    $scope.baseUrl = ''
    if _base_url != '/'
      $scope.baseUrl = _base_url
]
