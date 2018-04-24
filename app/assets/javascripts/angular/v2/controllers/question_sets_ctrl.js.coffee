App.controller 'QuestionSetsCtrl', ['$scope', '$state', 'QuestionSet',
($scope, $state, QuestionSet) ->

  $scope.createQuestionSet = () ->
    setNewQuestion(new QuestionSet(), true)

  $scope.cancelNewQuestionSet = () ->
    setNewQuestion(null, false)

  $scope.saveQuestionSet = () ->
    $scope.newQuestionSet.$save({} ,
      (data, headers) ->
        onQuestionSetSaved(data)
      (result, headers) ->
        alert(result.data.errors)
    )

  $scope.deleteQuestionSet = (questionSet) ->
    if confirm('Are you sure you want to delete ' + questionSet.title + '?')
      if questionSet.id
        questionSet.$delete({} ,
          (data, headers) ->
            $scope.questionSets.splice($scope.questionSets.indexOf(questionSet), 1)
          (result, headers) ->
            alert(result.data.errors)
        )

  onQuestionSetSaved = (questionSet) ->
    $scope.questionSets.push(questionSet)
    $scope.cancelNewQuestionSet()
    $state.go('questionSet', { id: questionSet.id })

  setNewQuestion = (questionSet, status) ->
    $scope.newQuestionSet = questionSet
    $scope.showNewQuestionSet = status

  setNewQuestion(new QuestionSet(), false)
  $scope.questionSets = QuestionSet.query({})

]

App.controller 'ShowQuestionSetCtrl', ['$scope', '$stateParams', '$location', 'QuestionSet',
($scope, $stateParams, $location, QuestionSet) ->

  $scope.updateQuestionSet = () ->
    if $scope.questionSet.id
      $scope.questionSet.$update({} ,
        (data, headers) ->
        (result, headers) ->
      )

  if $scope.questionSets and $stateParams.id
    $scope.questionSet = _.first(_.filter($scope.questionSets, (qs) -> qs.id == $stateParams.id))
  else if $stateParams.id and not $scope.questionSets
    $scope.questionSet = QuestionSet.get({'id': $stateParams.id})

]
