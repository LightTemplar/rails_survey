App.controller 'GridQuestionsCtrl', ['$scope', 'Question', 'Instrument', 
($scope, Question, Instrument) ->
  $scope.statuses = [true, false]
  $scope.questionCounter
  
  $scope.init = (project_id, instrument_id, grid_id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    $scope.grid_id = grid_id
    $scope.getGridQuestions()
    
  $scope.getGridQuestions = () ->
    $scope.instrument = Instrument.get({
      "project_id": $scope.project_id, 
      "id": $scope.instrument_id
      })
    $scope.questions = Question.query({
      "project_id": $scope.project_id, 
      "instrument_id": $scope.instrument_id, 
      "grid_id": $scope.grid_id
    })
  
  $scope.deleteQuestion = (question) ->
    if confirm("Are you sure you want to delete this question?")
      if (question.id)
        question.project_id = $scope.project_id
        question.instrument_id = $scope.instrument_id
        question.$delete({},
          (data) ->
            $scope.questions.splice($scope.questions.indexOf(question), 1)
          ,
          (data) ->
            alert "Failed to delete question"
          )
      else
        $scope.questions.splice($scope.questions.indexOf(question), 1)
  
  $scope.updateQuestion = (question) ->
    if (question.id)
      question.$update({}, 
        (data, headers) -> ++$scope.questionCounter,
        (result, headers) -> $scope.saveQuestionFailure(result, headers)
      )
    else
      question.$save({},
        (data, headers) -> ++$scope.questionCounter,
        (result, headers) -> $scope.saveQuestionFailure(result, headers)
      )
    
  $scope.saveQuestionFailure = (result, headers) ->
    angular.forEach result.data.errors, (error, field) ->
      alert error
    
  $scope.newQuestion = (grid) ->
    question = new Question()
    question.number_in_grid = $scope.questions.length + 1
    if ($scope.questions.length == 0)
      question.number_in_instrument = $scope.instrument.question_count + 1
    else
      lastQuestion = $scope.questions[$scope.questions.length - 1]
      question.number_in_instrument = lastQuestion.number_in_instrument + 1
    question.text = ""
    question.question_identifier = "q_#{$scope.project_id}_#{$scope.instrument_id}_#{$scope.uniqueId()}"
    question.question_type = grid.question_type
    question.instrument_id = $scope.instrument_id
    question.grid_id = grid.id
    question.project_id = $scope.project_id
    $scope.questions.push(question)
    
  $scope.uniqueId = ->
    new Date().getTime().toString(36).split("").reverse().join("")
      
  $scope.saveQuestions = ->
    $scope.questionCounter = 0
    angular.forEach $scope.questions, (question, index) ->
      $scope.updateQuestion(question)  
    $scope.checkQuestionStatus()
    
  $scope.checkQuestionStatus = () ->
    if ($scope.questionCounter == $scope.questions.length)
      $scope.getGridQuestions()
      $scope.questionCounter = 0
    else
      setTimeout (-> $scope.checkQuestionStatus()), 1000
      
]
