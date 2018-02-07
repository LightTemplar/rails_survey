App.controller 'QuestionSetsCtrl', ['$scope', 'QuestionSet', ($scope, QuestionSet) ->

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

  $scope.deleteQuestionSet = (questionSet) ->
    if confirm('Are you sure you want to delete ' + questionSet.title + '?')
      if questionSet.id
        questionSet.$delete({} ,
          (data, headers) ->
            $scope.questionSets.splice($scope.questionSets.indexOf(questionSet), 1)
          (result, headers) ->
        )

  setNewQuestion = (questionSet, status) ->
    $scope.newQuestionSet = questionSet
    $scope.showNewQuestionSet = status

  setNewQuestion(new QuestionSet(), false)
  $scope.questionSets = QuestionSet.query({})

]

App.controller 'ShowQuestionSetCtrl', ['$scope', '$routeParams', '$location', 'QuestionSet',
($scope, $routeParams, $location, QuestionSet) ->

  $scope.questionTranslations = (questionSet) ->
    $location.path('/question_translations/').search({
      question_set_id: questionSet.id
    })


  $scope.updateQuestionSet = () ->
    if $scope.questionSet.id
      $scope.questionSet.$update({} ,
        (data, headers) ->
        (result, headers) ->
      )

  if $scope.questionSets and $routeParams.id
    $scope.questionSet = _.first(_.filter($scope.questionSets, (qs) -> qs.id == $routeParams.id))
  else if $routeParams.id and not $scope.questionSets
    $scope.questionSet = QuestionSet.get({'id': $routeParams.id})

]
