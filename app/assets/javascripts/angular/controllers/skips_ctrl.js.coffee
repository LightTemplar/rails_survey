App.controller 'SkipsCtrl', ['$scope', '$filter', 'Skip', ($scope, $filter, Skip) ->
  $scope.skips = []
  $scope.init = (project_id, instrument_id, question_id, option_id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    $scope.question_id = question_id
    $scope.option_id = option_id
    currentQuestion = $filter('filter')($scope.$parent.$parent.questions, id: question_id)[0]
    $scope.questions = $scope.$parent.$parent.questionsAfter(currentQuestion)
    if $scope.option_id and $scope.question_id and $scope.instrument_id 
      $scope.skips = $scope.querySkips()

  $scope.querySkips = ->
    Skip.query(
      {
        "project_id": $scope.project_id,
        "instrument_id": $scope.instrument_id,
        "question_id": $scope.question_id,
        "option_id": $scope.option_id
      }
    )
    
  $scope.addQuestionsToSkip = ->
    $scope.showSkips = !$scope.showSkips

  $scope.saveQuestionsToSkip = () ->
    $scope.showSkips = !$scope.showSkips
    if ($scope.option_id?)
      for q in $scope.questions
        if q.checked == true
          skip = new Skip
          skip.project_id = $scope.project_id
          skip.instrument_id = $scope.instrument_id
          skip.question_id = q.id
          skip.option_id = $scope.option_id
          skip.question_identifier = q.question_identifier
          if $filter('filter')($scope.skips, question_identifier: q.question_identifier).length == 0
            $scope.skips.push(skip)
            skip.$save({},
              (data, headers) -> $scope.skips = $scope.querySkips(),
              (result, headers) -> alert "Error saving question to skip"
            )

  $scope.removeSkip = (skip) ->
    if confirm("Are you sure you want to delete this question from those to skip?")
      $scope.skips.splice($scope.skips.indexOf(skip), 1)
      skip.project_id = $scope.project_id
      skip.instrument_id = $scope.instrument_id
      skip.question_id = $scope.question_id
      skip.option_id = $scope.option_id
      skip.$delete({},
        (data, headers) -> $scope.skips = $scope.querySkips(),
        (result, headers) -> alert "Error deleting question to skip"
      )
  
]