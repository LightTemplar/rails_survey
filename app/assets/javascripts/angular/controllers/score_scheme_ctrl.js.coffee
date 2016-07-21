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
      modalInstance = $uibModal.open(
        animation: $scope.animationsEnabled,
        templateUrl: 'newScoreUnit.html',
        controller: 'ModalInstanceCtrl',
        size: size,
        resolve:
          scoreUnit: -> new ScoreUnit(
            project_id: $scope.project_id,
            score_scheme_id: $scope.score_scheme_id,
            instrument_id: $scope.score_scheme.instrument_id
          )
      )

      modalInstance.result.then ((scoreUnit) ->
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

]

App.controller 'ModalInstanceCtrl', ['$scope', '$uibModalInstance', 'scoreUnit', 'Question',
  ($scope, $uibModalInstance, scoreUnit, Question) ->
    $scope.scorableQuestionTypes = ['SELECT_ONE', 'SELECT_ONE_WRITE_OTHER']
    $scope.scoreUnit = scoreUnit
    $scope.questions = Question.query({
      "project_id": scoreUnit.project_id,
      "instrument_id": scoreUnit.instrument_id
    })
    $scope.scoreUnit.question_ids = []

    $scope.ok = () ->
      console.log "ok"
      angular.forEach $scope.questions, (question, index) ->
        if question.checked
          $scope.scoreUnit.question_ids.push(question.id)
      $uibModalInstance.close($scope.scoreUnit)

    $scope.cancel = () ->
      console.log "cancel"
      $uibModalInstance.dismiss('cancel')

]

App.controller 'ScoreUnitsCtrl', ['$scope', 'ScoreUnit', 'ScoreUnitQuestions', ($scope, ScoreUnit, ScoreUnitQuestions) ->

  $scope.initialize = (project_id, score_scheme_id, unit_id) ->
    $scope.project_id = project_id
    $scope.score_scheme_id = score_scheme_id
    $scope.score_unit_id = unit_id
    $scope.score_unit = ScoreUnit.get({project_id: project_id, score_scheme_id: score_scheme_id, id: unit_id})
    $scope.questions = ScoreUnitQuestions.query({project_id: project_id, score_scheme_id: score_scheme_id, id: unit_id})

]