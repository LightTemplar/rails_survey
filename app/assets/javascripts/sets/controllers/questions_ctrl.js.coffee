App.controller 'QuestionsCtrl', ['$scope', '$routeParams', '$location', 'Question',
($scope, $routeParams, $location, Question) ->
  $scope.multiple = $routeParams.multiple

  $scope.newQuestion = () ->
    $location.path '/question_sets/' + $scope.questionSet.id + '/questions/new'

  $scope.editQuestion = (question) ->
    $scope.currentQuestion = question

  $scope.done = () ->
    $location.path('/projects/' + $routeParams.project_id + '/instruments/' +
    $routeParams.instrument_id + '/instrument_questions').search({})

  $scope.back = () ->
    $location.path '/question_sets/'

  if $routeParams.id
    $scope.questions = Question.query({"question_set_id": $routeParams.id})

]

App.controller 'ShowQuestionCtrl', ['$scope', '$routeParams', '$location', '$route',
 'Question', 'Setting', 'OptionSet', 'Instruction', 'InstrumentQuestion',
 ($scope, $routeParams, $location, $route, Question, Setting, OptionSet,
 Instruction, InstrumentQuestion) ->

  $scope.toolBar = [
      ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'pre', 'quote'],
      ['justifyLeft', 'justifyCenter', 'justifyRight', 'indent', 'outdent'],
      ['bold', 'italics', 'underline', 'strikeThrough', 'ul', 'ol', 'redo', 'undo', 'clear'],
      ['html', 'wordcount', 'charcount']
  ]

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
        (data, headers) ->
          if $routeParams.instrument_id && $routeParams.display_id
              # $scope.multiple = 1 #$routeParams.multiple
              createInstrumentQuestion(data)
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

  createInstrumentQuestion = (question) ->
    if $routeParams.instrument_id
      iQuestion = new InstrumentQuestion()
      iQuestion.instrument_id = $routeParams.instrument_id
      iQuestion.question_id = question.id
      iQuestion.project_id = $routeParams.project_id
      iQuestion.display_id = $routeParams.display_id
      iQuestion.number_in_instrument = $routeParams.number_in_instrument
      iQuestion.$save({},
        (data, headers) ->
          if !$routeParams.multiple
            $location.path('/projects/' + $routeParams.project_id + '/instruments/' +
            $routeParams.instrument_id + '/instrument_questions').search({})
        (result, headers) ->
      )

  if $routeParams.id == 'new'
    $scope.question = new Question()
    $scope.question.text = ''
  else if $scope.questions and $routeParams.id
    $scope.question = _.first(_.filter($scope.questions, (q) -> q.id == $routeParams.id))
  else if $routeParams.id and not $scope.questions
    $scope.question = Question.get({'question_set_id': $routeParams.question_set_id,
    'id': $routeParams.id})

  $scope.settings = Setting.get({})
  $scope.optionSets = OptionSet.query({})
  $scope.instructions = Instruction.query({})

]
