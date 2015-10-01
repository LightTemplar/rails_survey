App.controller 'SkipsCtrl', ['$scope', '$filter', 'Skip', ($scope, $filter, Skip) ->
  $scope.optionSkips = []
  $scope.init = (project_id, instrument_id, question_id, option_id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    $scope.question_id = question_id
    $scope.option_id = option_id
    currentQuestion = $filter('filter')($scope.$parent.$parent.questions, id: question_id, true)[0]
    $scope.questions = $scope.$parent.$parent.questionsAfter(currentQuestion)
    $scope.filterOptionSkips()

  $scope.filterOptionSkips = ->
    if $scope.option_id and $scope.question_id and $scope.instrument_id
      $scope.optionSkips = $filter('filter')($scope.$parent.skips, option_id: $scope.option_id, true)

  $scope.addQuestionsToSkip = ->
    $scope.showSkips = !$scope.showSkips
    for question in $scope.questions
      question.checked = question.disabled = false
    for skip in $scope.optionSkips
      question = $filter('filter')($scope.questions, question_identifier: skip.question_identifier, true)[0]
      question.checked = question.disabled = true

  $scope.saveQuestionsToSkip = () ->
    $scope.showSkips = !$scope.showSkips
    if ($scope.option_id?)
      for question in $scope.questions
        if question.checked is true and ($filter('filter')($scope.optionSkips, question_identifier: question.question_identifier, true)).length is 0
          skip = new Skip()
          skip.project_id = $scope.project_id
          skip.instrument_id = $scope.instrument_id
          skip.question_id = question.id
          skip.option_id = $scope.option_id
          skip.question_identifier = question.question_identifier
          $scope.$parent.skips.push(skip)
          $scope.optionSkips.push(skip)
          skip.$save({},
            (data, headers) -> $scope.$parent.querySkips(),
            (result, headers) -> alert "Error saving question to skip"
          )

  $scope.removeSkip = (skip) ->
    if confirm("Are you sure you want to delete this question from those to skip?")
      $scope.$parent.skips.splice($scope.$parent.skips.indexOf(skip), 1)
      skip.project_id = $scope.project_id
      skip.instrument_id = $scope.instrument_id
      skip.question_id = $scope.question_id
      skip.option_id = $scope.option_id
      skip.$delete({},
        (data, headers) -> $scope.filterOptionSkips(),
        (result, headers) -> alert "Error deleting question to skip"
      )
  
]