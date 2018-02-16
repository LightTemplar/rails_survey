App.controller 'QuestionsCtrl', ['$scope', '$state', '$stateParams', '$location', 'Question',
($scope, $state, $stateParams, $location, Question) ->
  $scope.multiple = $stateParams.multiple

  $scope.newQuestion = () ->
    $location.path '/question_sets/' + $scope.questionSet.id + '/questions/new'

  $scope.editQuestion = (question) ->
    $scope.currentQuestion = question

  $scope.done = () ->
    $location.path('/projects/' + $stateParams.project_id + '/instruments/' +
    $stateParams.instrument_id + '/instrument_questions').search({})

  $scope.back = () ->
    $state.go('questionSets')

  if $stateParams.id
    $scope.questions = Question.query({"question_set_id": $stateParams.id})

]

App.controller 'ShowQuestionCtrl', ['$scope', '$stateParams', '$location', '$state',
 'Question', 'Setting', 'OptionSet', 'Instruction', 'InstrumentQuestion',
 ($scope, $stateParams, $location, $state, Question, Setting, OptionSet,
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
    $scope.question.question_set_id = $stateParams.question_set_id
    if $scope.question.id
      $scope.question.$update({} ,
        (data, headers) ->
          $scope.question = data
          navigateBackAndReload()
        (result, headers) ->
      )
    else
      $scope.question.$save({} ,
        (data, headers) ->
          $scope.question = data
          if $stateParams.instrument_id && $stateParams.display_id
              createInstrumentQuestion(data)
          navigateBackAndReload()
        (result, headers) ->
      )

  $scope.cancel = () ->
    if not $scope.question.id
      $scope.question = null
    $location.path '/question_sets/' + $stateParams.question_set_id

  $scope.deleteQuestion = () ->
    if confirm('Are you sure you want to delete this question?')
      if $scope.question.id
        $scope.question.$delete({},
        (data, headers) ->
          $location.path '/question_sets/' + $stateParams.question_set_id
        (result, headers) ->
        )
      else
        $location.path '/question_sets/' + $stateParams.question_set_id

  navigateBackAndReload = () ->
    $location.path('/question_sets/' + $stateParams.question_set_id)

  createInstrumentQuestion = (question) ->
    if $stateParams.instrument_id
      iQuestion = new InstrumentQuestion()
      iQuestion.instrument_id = $stateParams.instrument_id
      iQuestion.question_id = question.id
      iQuestion.project_id = $stateParams.project_id
      iQuestion.display_id = $stateParams.display_id
      iQuestion.number_in_instrument = $stateParams.number_in_instrument
      iQuestion.$save({},
        (data, headers) ->
          if !$stateParams.multiple
            $location.path('/projects/' + $stateParams.project_id + '/instruments/' +
            $stateParams.instrument_id + '/instrument_questions').search({})
        (result, headers) ->
      )

  if $state.current.name == "questionSetNewQuestion"
    $scope.question = new Question()
    $scope.question.text = ''
  else if $scope.questions and $stateParams.id
    $scope.question = _.first(_.filter($scope.questions, (q) -> q.id == $stateParams.id))
  else if $stateParams.id and not $scope.questions
    $scope.question = Question.get({'question_set_id': $stateParams.question_set_id,
    'id': $stateParams.id})

  $scope.settings = Setting.get({})
  $scope.allOptionSets = OptionSet.query({}, ->
    $scope.optionSets = _.where($scope.allOptionSets, {special: false})
    $scope.specialOptionSets = _.where($scope.allOptionSets, {special: true})
  )
  $scope.instructions = Instruction.query({})

]
