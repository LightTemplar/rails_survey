App.controller 'QuestionSetsCtrl', ['$scope', 'QuestionSet',
($scope, QuestionSet) ->

  $scope.createQuestionSet = () ->
    setNewQuestion(new QuestionSet(), true)

  $scope.cancelNewQuestionSet = () ->
    setNewQuestion(null, false)

  $scope.saveQuestionSet = () ->
    $scope.newQuestionSet.$save({} ,
      (data, headers) ->
      (result, headers) ->
    )
    $scope.questionSets.push($scope.newQuestionSet)
    $scope.cancelNewQuestionSet()

  setNewQuestion = (questionSet, status) ->
    $scope.newQuestionSet = questionSet
    $scope.showNewQuestionSet = status

  setNewQuestion(new QuestionSet(), false)
  $scope.questionSets = QuestionSet.query({})

]

App.controller 'ShowQuestionSetCtrl', ['$scope', '$routeParams', '$location',
'QuestionSet', ($scope, $routeParams, $location, QuestionSet) ->

  $scope.updateQuestionSet = () ->
    if $scope.questionSet.id
      $scope.questionSet.$update({} ,
        (data, headers) ->
        (result, headers) ->
      )

  $scope.deleteQuestionSet = () ->
    if confirm('Are you sure you want to delete this question set?')
      if $scope.questionSet.id
        $scope.questionSet.$delete({} ,
          (data, headers) ->
            $location.path '/question_sets'
          (result, headers) ->
        )

  if $scope.questionSets and $routeParams.id
    $scope.questionSet = _.first(_.filter($scope.questionSets, (qs) -> qs.id == $routeParams.id))
  else if $routeParams.id and not $scope.questionSets
    $scope.questionSet = QuestionSet.get({'id': $routeParams.id})

]
