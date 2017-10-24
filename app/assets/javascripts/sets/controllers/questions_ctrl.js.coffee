App.controller 'QuestionsCtrl', ['$scope', 'Question', ($scope, Question) ->
  $scope.textLimit = 50
  $scope.toolBar = [
    ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'pre', 'quote'],
    ['justifyLeft', 'justifyCenter', 'justifyRight', 'indent', 'outdent'],
    ['bold', 'italics', 'underline', 'strikeThrough', 'ul', 'ol', 'redo', 'undo', 'clear'],
    ['html', 'wordcount', 'charcount']
  ]

  $scope.init = (questionSet) ->
    $scope.questionSet = questionSet
    $scope.questions = Question.query({"question_set_id": $scope.questionSet.id})

  $scope.newQuestion = () ->
    question = new Question()
    $scope.currentQuestion = question
    $scope.questions.push(question)

  $scope.editQuestion = (question) ->
    $scope.currentQuestion = question

  $scope.questionTypes = () ->
    $scope.settings.question_types

  $scope.questionTypesWithOptions = (questionType) ->
    questionType in $scope.settings.question_with_options

  $scope.saveQuestion = (question) ->
    question.question_set_id = $scope.questionSet.id
    if $scope.currentQuestion.id
      $scope.currentQuestion.$update({} ,
        (data, headers) -> ,
        (result, headers) ->
      )
    else
      $scope.currentQuestion.$save({} ,
        (data, headers) -> ,
        (result, headers) ->
      )
    $scope.currentQuestion = null

]
