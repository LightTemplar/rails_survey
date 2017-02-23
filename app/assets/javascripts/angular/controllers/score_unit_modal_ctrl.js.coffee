App.controller 'ScoreUnitModalCtrl', ['$scope', '$uibModalInstance', 'scoreUnit', 'Question', '$filter', 'ScoreUnit', ($scope, $uibModalInstance, scoreUnit, Question, $filter, ScoreUnit) ->
  $scope.all_questions = []
  $scope.scoreUnit = scoreUnit
  $scope.scorableQuestionTypes = ScoreUnit.question_types({
    'project_id': scoreUnit.project_id,
    'score_scheme_id': scoreUnit.score_scheme_id
  } )
  $scope.questions = Question.query({
    'project_id': scoreUnit.project_id,
    'instrument_id': scoreUnit.instrument_id
  } , ->
    angular.copy($scope.questions, $scope.all_questions)
    if $scope.scoreUnit.question_type?
      $scope.questionTypeChanged()
  )
  $scope.scoreTypes = ScoreUnit.score_types({
    'project_id': scoreUnit.project_id,
    'score_scheme_id': scoreUnit.score_scheme_id
  } )

  if $scope.scoreUnit.score_type == 'multiple_select'
    $scope.scoreRange = []
    for number in [$scope.scoreUnit.min..$scope.scoreUnit.max]
      $scope.scoreRange.push( {value: number} )

  $scope.questionTypeChanged = () ->
    $scope.questions = $filter('filter')($scope.all_questions, question_type: $scope.scoreUnit.question_type, true)

  $scope.next = () ->
    if $scope.scoreUnit.score_type == 'single_select' || $scope.scoreUnit.score_type == 'multiple_select' || $scope.scoreUnit.score_type == 'multiple_select_sum'
      options = ScoreUnit.options({
        'project_id': $scope.scoreUnit.project_id,
        'score_scheme_id': $scope.scoreUnit.score_scheme_id,
        'question_ids[]': $scope.scoreUnit.question_ids
      } , ->
        option_scores = []
        angular.forEach options, (option, index) ->
          option_scores.push({label: option.text, option_id: option.id, value: ''} )
        $scope.scoreUnit.option_scores = option_scores
        $uibModalInstance.close($scope.scoreUnit)
      )
    else
      console.log($scope.scoreUnit.option_scores)
      $uibModalInstance.close($scope.scoreUnit)

  $scope.back = () ->
    $uibModalInstance.dismiss($scope.scoreUnit)

  $scope.cancel = () ->
    $uibModalInstance.dismiss('cancel')

  $scope.save = () ->
    if $scope.scoreUnit.score_type == 'multiple_select'
      selected_options = $filter('filter')($scope.scoreUnit.option_scores, selected: true, true)
      $scope.scoreUnit.option_scores = selected_options
    $uibModalInstance.close($scope.scoreUnit)

  $scope.add = (term) ->
    if term.label.length > 0
      newTerm = angular.copy(term)
      $scope.scoreUnit.option_scores.push({label: newTerm.label, value: '', exists: true} )
      $scope.scoreUnit.option_scores.push({label: newTerm.label, value: '', exists: false} )
      term.label = ''

  $scope.deleteSearchTerm = (options) ->
    if confirm('Are you sure you want to delete this search term?')
      deleteOption(option) for option in options

  $scope.someQuestionSelected = () ->
    if $scope.scoreUnit.question_ids? && $scope.scoreUnit.question_ids.length > 0 then true else false

  deleteOption = (option) ->
    option.project_id = $scope.scoreUnit.project_id
    option.score_scheme_id = $scope.scoreUnit.score_scheme_id
    if typeof option.$delete != 'function'
      removeOption(option)
    else
      option.$delete({} ,
      (data) ->
        removeOption(option)
      ,
      (data) ->
        alert 'Failed to delete option score'
      )

  removeOption = (option) ->
    $scope.scoreUnit.option_scores.splice($scope.scoreUnit.option_scores.indexOf(option), 1)

]