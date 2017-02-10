App.controller 'ScoreSchemeEditorCtrl', ['$scope', '$uibModal', '$filter', 'ScoreScheme', 'ScoreUnit', 'OptionScore', 'ScoreUnitQuestions', ($scope, $uibModal, $filter, ScoreScheme, ScoreUnit, OptionScore, ScoreUnitQuestions) ->

    $scope.initialize = (project_id, score_scheme_id) ->
      $scope.project_id = project_id
      $scope.score_scheme_id = score_scheme_id
      $scope.score_scheme = ScoreScheme.get({"project_id": project_id, "id": score_scheme_id} )
      $scope.score_units = ScoreUnit.query({"project_id": project_id, "score_scheme_id": score_scheme_id} )

    createScoreUnit = () ->
      return new ScoreUnit(
        project_id: $scope.project_id,
        score_scheme_id: $scope.score_scheme_id,
        instrument_id: $scope.score_scheme.instrument_id
        question_ids: []
      )

    $scope.newScoreUnit = (unit = createScoreUnit()) ->
      newScoreUnitModalView = $uibModal.open(
        templateUrl: 'newScoreUnit.html',
        controller: 'ScoreUnitModalCtrl',
        resolve:
          scoreUnit: -> unit
      )

      newScoreUnitModalView.result.then ((scoreUnit) ->
        if scoreUnit.question_type == 'SELECT_ONE' || scoreUnit.question_type == 'SELECT_ONE_WRITE_OTHER'
          templateUrl = 'singleSelect.html'
        else if scoreUnit.question_type == 'SELECT_MULTIPLE'
          templateUrl = 'multipleSelect.html'
        selectModalView = $uibModal.open(
          templateUrl: templateUrl,
          controller: 'ScoreUnitModalCtrl',
          resolve:
            scoreUnit: -> scoreUnit
        )

        selectModalView.result.then ((scoreUnit) ->
          scoreUnit.$save({} ,
            (data, headers) ->
              $scope.score_units.push(scoreUnit)
              return
            (result, headers) ->
              angular.forEach result.data.errors, (error, field) ->
                alert error
          )
        ), (reason) ->
          if reason.constructor.name == 'Resource'
            $scope.newScoreUnit(reason)
          return
      ), ->
        return

    $scope.deleteScoreUnit = (unit) ->
      if confirm("Are you sure you want to delete this score unit?")
        unit.project_id = $scope.project_id
        unit.$delete({} ,
          (data) ->
            $scope.score_units.splice($scope.score_units.indexOf(unit), 1)
        ,
          (data) ->
            alert "Failed to delete score unit"
        )

    $scope.editScoreUnit = (unit) ->
      unit.project_id = $scope.project_id
      unit.instrument_id = $scope.score_scheme.instrument_id
      scoreUnitQuestions = ScoreUnitQuestions.query({
        project_id: $scope.project_id,
        score_scheme_id: unit.score_scheme_id,
        id: unit.id
      } , ->
        unit.question_ids = scoreUnitQuestions.map((question) -> question.id)
        editModalView = $uibModal.open(
          templateUrl: 'newScoreUnit.html',
          controller: 'ScoreUnitModalCtrl',
          resolve: scoreUnit: -> unit
        )

        editModalView.result.then ((scoreUnit) ->
          optionScores = OptionScore.query({
            project_id: $scope.project_id,
            score_scheme_id: scoreUnit.score_scheme_id,
            score_unit_id: scoreUnit.id
          } , ->
            angular.forEach optionScores, (optionScore, index) ->
              savedOptionScore = $filter('filter')(scoreUnit.option_scores, option_id: optionScore.option_id, true)[0]
              savedOptionScoreIndex = scoreUnit.option_scores.indexOf(savedOptionScore)
              if savedOptionScoreIndex != - 1
                scoreUnit.option_scores[savedOptionScoreIndex] = optionScore
          )

          secondEditModalView = $uibModal.open(
            templateUrl: 'singleSelect.html',
            controller: 'ScoreUnitModalCtrl',
            resolve: scoreUnit: -> scoreUnit
          )

          secondEditModalView.result.then ((unit) ->
            unit.$update({} ,
              (data, headers) ->
                $scope.$broadcast('UNIT_UPDATED', data.id)
              (result, headers) ->
            )
          ), (reason) ->
            if reason.constructor.name == 'Resource'
              $scope.editScoreUnit(reason)
          return
        ), ->
        return
      )

]