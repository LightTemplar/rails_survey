App.controller 'InstrumentsCtrl', ['$scope', '$stateParams', 'Instrument',
($scope, $stateParams, Instrument) ->
  $scope.project_id = $stateParams.id
  $scope.instruments = Instrument.query({"project_id": $stateParams.id} )
]

App.controller 'ShowInstrumentCtrl', ['$scope', '$stateParams', 'Instrument',
($scope, $stateParams, Instrument) ->
  $scope.project_id = $stateParams.project_id
  $scope.id = $stateParams.id
  
]
