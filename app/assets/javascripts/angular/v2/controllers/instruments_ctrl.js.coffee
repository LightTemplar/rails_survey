App.controller 'ShowInstrumentCtrl', ['$scope', '$stateParams', 'Instrument',
($scope, $stateParams, Instrument) ->
  $scope.project_id = $stateParams.project_id
  $scope.id = $stateParams.id

]
