App.controller 'InstrumentsCtrl', ['$scope', 'Instrument', ($scope, Instrument) ->
  $scope.initialize = (project_id) ->
    $scope.instruments = Instrument.query({"project_id": project_id} )
]
