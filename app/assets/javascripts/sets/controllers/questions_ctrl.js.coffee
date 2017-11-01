App.controller 'QuestionsCtrl', ['$scope', '$routeParams', '$location', 'Question',
($scope, $routeParams, $location, Question) ->

  $scope.newQuestion = () ->
    $location.path '/question_sets/' + $scope.questionSet.id + '/questions/new'

  $scope.editQuestion = (question) ->
    $scope.currentQuestion = question

  if $routeParams.id
    $scope.questions = Question.query({"question_set_id": $routeParams.id})

]

App.controller 'ShowQuestionCtrl', ['$scope', '$routeParams', '$location', '$route',
 'Question', 'Setting', 'OptionSet', 'Instruction'
 ($scope, $routeParams, $location, $route, Question, Setting, OptionSet, Instruction) ->

  $scope.questionTypes = () ->
    $scope.settings.question_types

  $scope.questionTypesWithOptions = (questionType) ->
    if $scope.settings.question_with_options
      questionType in $scope.settings.question_with_options

  $scope.saveQuestion = () ->
    $scope.question.question_set_id = $routeParams.question_set_id
    if $scope.question.id
      $scope.question.$update({} ,
        (data, headers) -> ,
        navigateBackAndReload()
        (result, headers) ->
      )
    else
      $scope.question.$save({} ,
        (data, headers) -> ,
        navigateBackAndReload()
        (result, headers) ->
      )

  $scope.cancel = () ->
    if not $scope.question.id
      $scope.question = null
    $location.path '/question_sets/' + $routeParams.question_set_id

  $scope.deleteQuestion = () ->
    if confirm('Are you sure you want to delete this question?')
      if $scope.question.id
        $scope.question.$delete({},
        (data, headers) ->
          $location.path '/question_sets/' + $routeParams.question_set_id
        (result, headers) ->
        )
      else
        $location.path '/question_sets/' + $routeParams.question_set_id

  navigateBackAndReload = () ->
    $location.path '/question_sets/' + $routeParams.question_set_id
    $route.reload()

  if $routeParams.id == 'new'
    $scope.question = new Question()
  else if $scope.questions and $routeParams.id
    $scope.question = _.first(_.filter($scope.questions, (q) -> q.id == $routeParams.id))
  else if $routeParams.id and not $scope.questions
    $scope.question = Question.get({'question_set_id': $routeParams.question_set_id,
    'id': $routeParams.id})

  $scope.settings = Setting.get({})
  $scope.optionSets = OptionSet.query({})
  $scope.instructions = Instruction.query({})

]
