App.controller 'GridsCtrl', ['$scope', 'Grid', 'Question', 'Instrument', 'GridLabel', ($scope, Grid, Question, Instrument, GridLabel) ->
    $scope.init = (project_id, instrument_id) ->
      $scope.project_id = project_id
      $scope.instrument_id = instrument_id
      $scope.displayNewTemplate = false
      $scope.gridQuestionTypes = ['SELECT_ONE', 'SELECT_MULTIPLE']
      $scope.grids = Grid.query({"project_id": project_id, "instrument_id": instrument_id})
      $scope.getInstrument()

    $scope.newGrid = ->
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

    $scope.newQuestion = (grid) ->
      $scope.current_grid = grid
      question = new Question()
      $scope.questions = Question.query({
          "project_id": $scope.project_id,
          "instrument_id": $scope.instrument_id,
          "grid_id": grid.id
        },
        -> $scope.assignQuestionAttributes(question, grid))

    $scope.assignQuestionAttributes = (question, grid) ->
      question.number_in_grid = $scope.questions.length + 1
      question.number_in_instrument = $scope.instrument.previous_question_count + 1
      question.text = "Placeholder question text"
      question.question_identifier = "q_#{$scope.project_id}_#{$scope.instrument_id}_#{$scope.uniqueId()}"
      question.question_type = grid.question_type
      question.instrument_id = $scope.instrument_id
      question.grid_id = grid.id
      question.project_id = $scope.project_id
      question.$save({},
        (data, headers) -> $scope.saveQuestionSuccess(data, headers),
        (result, headers) -> $scope.saveQuestionFailure(result, headers)
      )

    $scope.uniqueId = ->
      new Date().getTime().toString(36).split("").reverse().join("")

    $scope.saveQuestionSuccess = (data, headers) ->
      $scope.getInstrument()
      $scope.$broadcast('GRID_CHANGED', data.id)

    $scope.saveQuestionFailure = (result, headers) ->
      angular.forEach result.data.errors, (error, field) ->
        alert error

    $scope.getInstrument = ->
      $scope.instrument = Instrument.get({"project_id": $scope.project_id, "id": $scope.instrument_id})

    $scope.editGrid = (grid) ->
      if ($scope.edit_grid == grid)
        $scope.edit_grid = null
      else
        $scope.edit_grid = grid
  
]
