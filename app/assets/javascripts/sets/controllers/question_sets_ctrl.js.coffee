App.controller 'QuestionSetsCtrl', ['$scope', 'QuestionSet', 'OptionSet', 'Question', 'Setting',
($scope, QuestionSet, OptionSet, Question, Setting) ->

  $scope.settings = Setting.get({})
  $scope.questionSets = QuestionSet.query({})
  $scope.optionSets = OptionSet.query({})

  $scope.viewQuestionSet = (questionSet) ->
    $scope.currentQuestionSet = questionSet

  $scope.newQuestionSet = () ->
    questionSet = new QuestionSet()
    $scope.currentQuestionSet = questionSet
    $scope.questionSets.push(questionSet)

  $scope.editQuestionSet = (questionSet) ->
    $scope.currentQuestionSet = questionSet

  $scope.saveQuestionSet = () ->
    if $scope.currentQuestionSet.id
      $scope.currentQuestionSet.$update({} ,
        (data, headers) -> ,
        (result, headers) ->
      )
    else
      $scope.currentQuestionSet.$save({} ,
        (data, headers) -> ,
        (result, headers) ->
      )
    $scope.currentQuestionSet = null

]
