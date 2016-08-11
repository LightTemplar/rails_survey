App.controller 'ICScoreSchemesCtrl', ['$scope', 'ScoreScheme', 'Instrument', ($scope, ScoreScheme,
  Instrument) ->
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

App.controller 'SEScoreSchemesCtrl', ['$scope', '$uibModal', 'ScoreScheme', 'ScoreUnit',
  ($scope, $uibModal, ScoreScheme, ScoreUnit) ->
    $scope.animationsEnabled = true

    $scope.initialize = (project_id, score_scheme_id) ->
      $scope.project_id = project_id
      $scope.score_scheme_id = score_scheme_id
      $scope.score_scheme = ScoreScheme.get({"project_id": project_id, "id": score_scheme_id})
      $scope.score_units = ScoreUnit.query({"project_id": project_id, "score_scheme_id": score_scheme_id})

    $scope.newScoreUnit = (size) ->
      firstModalView = $uibModal.open(
        animation: $scope.animationsEnabled,
        templateUrl: 'newScoreUnitFirstPage.html',
        controller: 'ModalInstanceCtrl',
        size: size,
        resolve:
          scoreUnit: -> new ScoreUnit(
            project_id: $scope.project_id,
            score_scheme_id: $scope.score_scheme_id,
            instrument_id: $scope.score_scheme.instrument_id
          )
      )

      firstModalView.result.then ((scoreUnit) ->
        secondModalView = $uibModal.open(
          animation: $scope.animationsEnabled,
          templateUrl: 'newScoreUnitSecondPage.html',
          controller: 'ModalInstanceCtrl',
          size: size,
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
        ), ->
        return
      ), ->
        return

]

App.controller 'ModalInstanceCtrl', ['$scope', '$uibModalInstance', 'scoreUnit', 'Question', 'ScoreUnitOptions',
  ($scope, $uibModalInstance, scoreUnit, Question, ScoreUnitOptions) ->
    $scope.scorableQuestionTypes = ['SELECT_ONE', 'SELECT_ONE_WRITE_OTHER']
    $scope.scoreUnit = scoreUnit
    $scope.questions = Question.query({
      "project_id": scoreUnit.project_id,
      "instrument_id": scoreUnit.instrument_id
    })

    $scope.next = () ->
      question_ids = []
      angular.forEach $scope.questions, (question, index) ->
        if question.checked
          question_ids.push(question.id)
      $scope.scoreUnit.question_ids = question_ids
      options = ScoreUnitOptions.query({
        project_id: $scope.scoreUnit.project_id,
        score_scheme_id: $scope.scoreUnit.score_scheme_id,
        'question_ids[]': $scope.scoreUnit.question_ids
      }, ->
        option_scores = []
        angular.forEach options, (option, index) ->
          option_scores.push({text: option.text, option_id: option.id, score: ''})
        $scope.scoreUnit.option_scores = option_scores
        $uibModalInstance.close($scope.scoreUnit)
      )

    $scope.cancel = () ->
      $uibModalInstance.dismiss('cancel')

    $scope.save = () ->
      $uibModalInstance.close($scope.scoreUnit)

]

App.controller 'ScoreUnitsCtrl', ['$scope', 'ScoreUnit', 'ScoreUnitQuestions', 'OptionScore',
  ($scope, ScoreUnit, ScoreUnitQuestions, OptionScore) ->
    $scope.initialize = (project_id, score_scheme_id, score_unit_id) ->
      $scope.project_id = project_id
      $scope.score_scheme_id = score_scheme_id
      $scope.score_unit_id = score_unit_id
      $scope.score_unit = ScoreUnit.get({project_id: project_id, score_scheme_id: score_scheme_id, id: score_unit_id})
      $scope.questions = ScoreUnitQuestions.query({
        project_id: project_id,
        score_scheme_id: score_scheme_id,
        id: score_unit_id
      })
      $scope.option_scores = OptionScore.query({
        project_id: project_id,
        score_scheme_id: score_scheme_id,
        score_unit_id: score_unit_id
      })

]