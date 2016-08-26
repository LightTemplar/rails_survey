App.controller 'ScoreSchemesCtrl', ['$scope', 'ScoreScheme', 'Instrument', ($scope, ScoreScheme, Instrument) ->
  $scope.showIndex = true

  $scope.initialize = (project_id) ->
    $scope.project_id = project_id
    $scope.score_schemes = ScoreScheme.query({"project_id": project_id})
    $scope.instruments = Instrument.query({"project_id": project_id})

  $scope.toggleViews = () ->
    $scope.showIndex = !$scope.showIndex

  $scope.newScheme = () ->
    $scope.toggleViews()
    $scope.scheme = new ScoreScheme()
    $scope.scheme.project_id = $scope.project_id

  $scope.handleSelectedInstrument = (instrumentId) ->
    $scope.scheme.instrument_id = instrumentId

  $scope.createScheme = () ->
    if !$scope.scheme.instrument_id || !$scope.scheme.title
      alert 'Missing field'
    else
      $scope.scheme.$save({},
        (data, headers) ->
          $scope.score_schemes.push($scope.scheme)
          $scope.toggleViews()
        (result, headers) ->
          angular.forEach result.data.errors, (error, field) ->
            alert error
      )

]

App.controller 'ScoreSchemesEditorCtrl', ['$scope', '$uibModal', '$filter', 'ScoreScheme', 'ScoreUnit', 'OptionScore',
  'ScoreUnitQuestions', ($scope, $uibModal, $filter, ScoreScheme, ScoreUnit, OptionScore, ScoreUnitQuestions) ->

    $scope.initialize = (project_id, score_scheme_id) ->
      $scope.project_id = project_id
      $scope.score_scheme_id = score_scheme_id
      $scope.score_scheme = ScoreScheme.get({"project_id": project_id, "id": score_scheme_id})
      $scope.score_units = ScoreUnit.query({"project_id": project_id, "score_scheme_id": score_scheme_id})

    createScoreUnit = () ->
      return new ScoreUnit(
        project_id: $scope.project_id,
        score_scheme_id: $scope.score_scheme_id,
        instrument_id: $scope.score_scheme.instrument_id
        question_ids: []
      )

    $scope.newScoreUnit = (unit = createScoreUnit()) ->
      firstModalView = $uibModal.open(
        templateUrl: 'newScoreUnitFirstPage.html',
        controller: 'ScoreUnitModalCtrl',
        resolve:
          scoreUnit: -> unit
      )

      firstModalView.result.then ((scoreUnit) ->
        secondModalView = $uibModal.open(
          templateUrl: 'newScoreUnitSecondPage.html',
          controller: 'ScoreUnitModalCtrl',
          resolve:
            scoreUnit: -> scoreUnit
        )

        secondModalView.result.then ((scoreUnit) ->
          scoreUnit.$save({},
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
        unit.$delete({},
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
      }, ->
        unit.question_ids = scoreUnitQuestions.map((question) -> question.id)
        editModalView = $uibModal.open(
          templateUrl: 'newScoreUnitFirstPage.html',
          controller: 'ScoreUnitModalCtrl',
          resolve: scoreUnit: -> unit
        )

        editModalView.result.then ((scoreUnit) ->
          optionScores = OptionScore.query({
            project_id: $scope.project_id,
            score_scheme_id: scoreUnit.score_scheme_id,
            score_unit_id: scoreUnit.id
          }, ->
            angular.forEach optionScores, (optionScore, index) ->
              savedOptionScore = $filter('filter')(scoreUnit.option_scores, option_id: optionScore.option_id, true)[0]
              savedOptionScoreIndex = scoreUnit.option_scores.indexOf(savedOptionScore)
              if savedOptionScoreIndex != -1
                scoreUnit.option_scores[savedOptionScoreIndex] = optionScore
          )

          secondEditModalView = $uibModal.open(
            templateUrl: 'newScoreUnitSecondPage.html',
            controller: 'ScoreUnitModalCtrl',
            resolve: scoreUnit: -> scoreUnit
          )

          secondEditModalView.result.then ((unit) ->
            unit.$update({},
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

App.controller 'ScoreUnitModalCtrl', ['$scope', '$uibModalInstance', 'scoreUnit', 'Question', 'ScoreUnitOptions',
  '$filter', ($scope, $uibModalInstance, scoreUnit, Question, ScoreUnitOptions, $filter) ->
    $scope.scorableQuestionTypes = ['SELECT_ONE', 'SELECT_ONE_WRITE_OTHER']
    $scope.all_questions = []
    $scope.scoreUnit = scoreUnit
    $scope.questions = Question.query({
      "project_id": scoreUnit.project_id,
      "instrument_id": scoreUnit.instrument_id
    }, ->
      angular.copy($scope.questions, $scope.all_questions)
      if $scope.scoreUnit.question_type?
        $scope.questionTypeChanged()
    )

    $scope.questionTypeChanged = () ->
      $scope.questions = $filter('filter')($scope.all_questions, question_type: $scope.scoreUnit.question_type, true)

    $scope.next = () ->
      options = ScoreUnitOptions.query({
        project_id: $scope.scoreUnit.project_id,
        score_scheme_id: $scope.scoreUnit.score_scheme_id,
        'question_ids[]': $scope.scoreUnit.question_ids
      }, ->
        option_scores = []
        angular.forEach options, (option, index) ->
          option_scores.push({label: option.text, option_id: option.id, value: ''})
        $scope.scoreUnit.option_scores = option_scores
        $uibModalInstance.close($scope.scoreUnit)
      )

    $scope.back = () ->
      $uibModalInstance.dismiss($scope.scoreUnit)

    $scope.cancel = () ->
      $uibModalInstance.dismiss('cancel')

    $scope.save = () ->
      $uibModalInstance.close($scope.scoreUnit)

    $scope.someQuestionSelected = () ->
      return $scope.scoreUnit.question_ids.length > 0 ? true: false

]

App.controller 'ScoreUnitsCtrl', ['$scope', 'ScoreUnit', 'ScoreUnitQuestions', 'OptionScore',
  ($scope, ScoreUnit, ScoreUnitQuestions, OptionScore) ->
    $scope.initialize = (project_id, score_scheme_id, score_unit_id) ->
      $scope.project_id = project_id
      $scope.score_scheme_id = score_scheme_id
      $scope.score_unit_id = score_unit_id
      $scope.score_unit = ScoreUnit.get({project_id: project_id, score_scheme_id: score_scheme_id, id: score_unit_id})
      $scope.getQuestionsAndOptionScores()

    $scope.getQuestionsAndOptionScores = () ->
      $scope.questions = ScoreUnitQuestions.query({
        project_id: $scope.project_id,
        score_scheme_id: $scope.score_scheme_id,
        id: $scope.score_unit_id
      })
      $scope.option_scores = OptionScore.query({
        project_id: $scope.project_id,
        score_scheme_id: $scope.score_scheme_id,
        score_unit_id: $scope.score_unit_id
      })

    $scope.$on('UNIT_UPDATED', (event, id) ->
      if (id? && id == $scope.score_unit_id)
        $scope.getQuestionsAndOptionScores()
    )

]