App.controller 'ScoreUnitsCtrl', ['$scope', 'ScoreUnit', 'ScoreUnitQuestions', 'OptionScore', ($scope, ScoreUnit, ScoreUnitQuestions, OptionScore) ->
    $scope.initialize = (project_id, score_scheme_id, score_unit_id) ->
      $scope.project_id = project_id
      $scope.score_scheme_id = score_scheme_id
      $scope.score_unit_id = score_unit_id
      $scope.score_unit = ScoreUnit.get({project_id: project_id, score_scheme_id: score_scheme_id, id: score_unit_id} )
      $scope.getQuestionsAndOptionScores()

    $scope.getQuestionsAndOptionScores = () ->
      $scope.questions = ScoreUnitQuestions.query({
        project_id: $scope.project_id,
        score_scheme_id: $scope.score_scheme_id,
        id: $scope.score_unit_id
      } )
      $scope.option_scores = OptionScore.query({
        project_id: $scope.project_id,
        score_scheme_id: $scope.score_scheme_id,
        score_unit_id: $scope.score_unit_id
      } )

    $scope.$on('UNIT_UPDATED', (event, id) ->
      if (id? && id == $scope.score_unit_id)
        $scope.getQuestionsAndOptionScores()
    )

    $scope.isSingleSelect = (unit) ->
      unit.question_type == 'SELECT_ONE' || unit.question_type == 'SELECT_ONE_WRITE_OTHER'

    $scope.isMultipleSelect = (unit) ->
      unit.question_type == 'SELECT_MULTIPLE' || unit.question_type == 'SELECT_MULTIPLE_WRITE_OTHER'

]