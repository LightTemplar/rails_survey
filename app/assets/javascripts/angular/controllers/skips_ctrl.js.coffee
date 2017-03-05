App.controller 'SkipsCtrl', ['$scope', '$filter', 'Skip', 'Question', ($scope, $filter, Skip, Question) ->

  $scope.skips = (angular.copy(skip, new Skip) for skip in $filter('filter')($scope.question.option_skips, option_id: $scope.option.id, true)) if $scope.question.option_skips?

  currentQuestion = $filter('filter')($scope.questions, id: $scope.question_id, true)[0]

  $scope.$watch 'allQuestions', ((newValue, oldValue, scope) ->
    questions = $scope.allQuestions.slice(currentQuestion.number_in_instrument, $scope.allQuestions.length)
    $scope.questions = (angular.copy(q, new Question) for q in questions)
  ), true

  $scope.addQuestionsToSkip = ->
    $scope.showSkips = ! $scope.showSkips
    for question in $scope.questions
      question.checked = question.disabled = false
    for skip in $scope.skips
      question = $filter('filter')($scope.questions, question_identifier: skip.question_identifier, true)[0]
      question.checked = question.disabled = true

  $scope.saveQuestionsToSkip = () ->
    $scope.showSkips = ! $scope.showSkips
    if $scope.option.id?
      for q in $scope.questions
        if q.checked == true
          skip = new Skip
          skip.project_id = $scope.project_id
          skip.instrument_id = $scope.instrument_id
          skip.question_id = q.id
          skip.option_id = $scope.option.id
          skip.question_identifier = angular.copy(q.question_identifier)
          if $filter('filter')($scope.skips, question_identifier: q.question_identifier, true).length == 0
            $scope.skips.push(skip)
            skip.$save({} ,
              (data, headers) ->
                skip.id = data.id
                $scope.question.option_skips.push(skip)
              ,
              (result, headers) -> alert "Error saving question to skip"
            )

  $scope.removeSkip = (skip) ->
    if confirm("Are you sure you want to delete this question from those to skip?")
      $scope.skips.splice($scope.skips.indexOf(skip), 1)
      skip.project_id = $scope.project_id
      skip.instrument_id = $scope.instrument_id
      skip.question_id = $scope.question_id
      skip.option_id = $scope.option.id
      skip.$delete({} ,
        (data, headers) -> $scope.question.option_skips.splice($scope.question.option_skips.indexOf(skip), 1),
        (result, headers) -> alert "Error deleting question to skip"
      )

]