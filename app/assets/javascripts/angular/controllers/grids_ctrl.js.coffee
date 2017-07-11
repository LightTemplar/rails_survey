App.controller 'GridsCtrl', ['$scope', 'Grid', 'Question', 'Instrument', 'GridLabel', ($scope, Grid, Question, Instrument, GridLabel) ->
    $scope.init = (project_id, instrument_id) ->
      $scope.project_id = project_id
      $scope.instrument_id = instrument_id
      $scope.displayNewTemplate = false
      $scope.gridQuestionTypes = ['SELECT_ONE', 'SELECT_MULTIPLE']
      $scope.grids = Grid.query({"project_id": project_id, "instrument_id": instrument_id})
      $scope.instrument = Instrument.get({"project_id": project_id, "id": instrument_id})

    $scope.newGrid = ->
      $scope.edit_grid = null
      $scope.displayNewTemplate = !$scope.displayNewTemplate
      $scope.grid = new Grid()
      $scope.grid.instrument_id = $scope.instrument_id
      $scope.grid.project_id = $scope.project_id

    $scope.saveGrid = ->
      $scope.displayNewTemplate = false
      $scope.grid.$save({},
        (data, headers) -> $scope.saveGridSuccess(data, headers),
        (result, headers) -> $scope.saveGridFailure(result, headers)
      )

    $scope.saveGridSuccess = (data, headers) ->
      $scope.$broadcast('GRID_SAVED', data.id)
      $scope.grids.push($scope.grid)

    $scope.saveGridFailure = (result, headers) ->
      angular.forEach result.data.errors, (error, field) ->
        alert error

    $scope.deleteGrid = (grid) ->
      if confirm("Are you sure you want to delete this grid?")
        grid.project_id = $scope.project_id
        grid.instrument_id = $scope.instrument_id
        grid.$delete({},
          (data) ->
            grid.id = null
        ,
          (data) ->
            alert "Failed to delete grid"
        )
        $scope.grids.splice($scope.grids.indexOf(grid), 1)

    $scope.updateGrid = (grid) ->
      grid.project_id = $scope.project_id
      grid.$update({},
        (data) ->,
        (data) ->
          alert "Failed to update grid"
      )

    $scope.editGrid = (grid) ->
      if ($scope.edit_grid == grid)
        $scope.edit_grid = null
      else
        $scope.edit_grid = grid
  
]
