App.controller 'ShowInstrumentCtrl', ['$scope', '$stateParams', 'Instrument', 'Project', 'Setting',
'$state', ($scope, $stateParams, Instrument, Project, Setting, $state) ->
  $scope.projects = Project.query({})
  $scope.project_id = $stateParams.project_id
  $scope.id = $stateParams.id
  $scope.settings = Setting.get({}, ->
    $scope.displayTypes = $scope.settings.copy_display_types
  )

  $scope.copyInstrument = () ->
    $scope.showCopy = true
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


]
