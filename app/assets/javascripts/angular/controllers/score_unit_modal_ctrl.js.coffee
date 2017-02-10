App.controller 'ScoreUnitModalCtrl', ['$scope', '$uibModalInstance', 'scoreUnit', 'Question', 'ScoreUnitOptions', '$filter',
($scope, $uibModalInstance, scoreUnit, Question, ScoreUnitOptions, $filter) ->
    $scope.scorableQuestionTypes = ['SELECT_ONE', 'SELECT_ONE_WRITE_OTHER', 'SELECT_MULTIPLE', 'SELECT_MULTIPLE_WRITE_OTHER']
    $scope.all_questions = []
    $scope.scoreUnit = scoreUnit
    $scope.questions = Question.query({
      "project_id": scoreUnit.project_id,
      "instrument_id": scoreUnit.instrument_id
    } , ->
      angular.copy($scope.questions, $scope.all_questions)
      if $scope.scoreUnit.question_type?
        $scope.questionTypeChanged()
    )

    multipleSelect = (scoreUnit) ->
      scoreUnit.question_type == 'SELECT_MULTIPLE' || scoreUnit.question_type == 'SELECT_MULTIPLE_WRITE_OTHER'

    if multipleSelect($scope.scoreUnit)
      $scope.scoreRange = []
      for number in [$scope.scoreUnit.min..$scope.scoreUnit.max]
        $scope.scoreRange.push( {value: number} )

    $scope.questionTypeChanged = () ->
      $scope.questions = $filter('filter')($scope.all_questions, question_type: $scope.scoreUnit.question_type, true)

    $scope.next = () ->
      options = ScoreUnitOptions.query({
        project_id: $scope.scoreUnit.project_id,
        score_scheme_id: $scope.scoreUnit.score_scheme_id,
        'question_ids[]': $scope.scoreUnit.question_ids
      } , ->
        option_scores = []
        angular.forEach options, (option, index) ->
          option_scores.push({label: option.text, option_id: option.id, value: ''} )
        $scope.scoreUnit.option_scores = option_scores
        $uibModalInstance.close($scope.scoreUnit)
      )

    $scope.back = () ->
      $uibModalInstance.dismiss($scope.scoreUnit)

    $scope.cancel = () ->
      $uibModalInstance.dismiss('cancel')

    $scope.save = () ->
      if multipleSelect($scope.scoreUnit)
        selected_options = $filter('filter')($scope.scoreUnit.option_scores, selected: true, true)
        $scope.scoreUnit.option_scores = selected_options
      $uibModalInstance.close($scope.scoreUnit)

    $scope.someQuestionSelected = () ->
      return $scope.scoreUnit.question_ids.length > 0 ? true: false

]