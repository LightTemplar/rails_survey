App.controller 'CriticalResponseCtrl', ['$scope', '$stateParams', 'CriticalResponse', 'Instruction', 'Option', 'Question',
($scope, $stateParams, CriticalResponse, Instruction, Option, Question) ->

  $scope.criticalResponses = CriticalResponse.query({
    'question_set_id': $stateParams.question_set_id,
    'question_id': $stateParams.id
  })
  $scope.question = Question.get({
    'question_set_id': $stateParams.question_set_id,
    'id': $stateParams.id
  }, ->
    $scope.options = Option.query({
      'option_set_id': $scope.question.option_set_id
    })
  )
  $scope.instructions = Instruction.query({})

  $scope.addCriticalResponse = () ->
    criticalResponse = new CriticalResponse()
    criticalResponse.question_identifier = $scope.question.question_identifier
    $scope.criticalResponses.push(criticalResponse)

  $scope.save = (criticalResponse) ->
    criticalResponse.question_set_id = $stateParams.question_set_id
    criticalResponse.question_id = $stateParams.id
    if criticalResponse.id
      criticalResponse.$update({})
    else
      criticalResponse.$save({})

  $scope.delete =(criticalResponse) ->
    criticalResponse.question_set_id = $stateParams.question_set_id
    criticalResponse.question_id = $stateParams.id
    if criticalResponse.id
      criticalResponse.$delete({})
    $scope.criticalResponses.splice($scope.criticalResponses.indexOf(criticalResponse), 1)

]
