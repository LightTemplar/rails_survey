App.controller 'LanguageTranslationsCtrl', ['$scope', '$stateParams', '$location', 'Setting',
($scope, $stateParams, $location, Setting) ->
  $scope.question_set_id = $stateParams.question_set_id
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0,1)
    $scope.languages = $scope.settings.languages
  )

]

App.controller 'OptionTranslationsCtrl', ['$scope', '$stateParams', 'Setting',
'Options', 'OptionTranslation', ($scope, $stateParams, Setting, Options, OptionTranslation) ->
  $scope.language = $stateParams.language
  $scope.options = Options.query({})
  $scope.option_translations = OptionTranslation.query({'language': $scope.language})

  $scope.translation_for = (option) ->
    ot = _.findWhere($scope.option_translations, {option_id: option.id})
    if ot == undefined
      ot = new OptionTranslation()
      ot.language = $scope.language
      ot.option_id = option.id
      ot.text = ""
      $scope.option_translations.push(ot)
    ot

  $scope.save = () ->
    angular.forEach $scope.option_translations, (ot, index) ->
      if ot.id
        ot.$update({})
      else if ot.text != ""
        ot.$save({})

]

App.controller 'QuestionTranslationsCtrl', ['$scope', '$stateParams', 'Setting',
'Questions', 'QuestionTranslation', 'Question', ($scope, $stateParams, Setting,
Questions, QuestionTranslation, Question) ->
  $scope.toolBar = [
      ['justifyLeft', 'justifyCenter', 'justifyRight'],
      ['bold', 'italics', 'underline', 'ul', 'ol', 'clear'],
      ['html', 'wordcount', 'charcount']
  ]

  $scope.translationFor = (question) ->
    qt = _.findWhere($scope.questionTranslations, {question_id: question.id})
    if qt == undefined
      qt = new QuestionTranslation()
      qt.language = $scope.language
      qt.question_id = question.id
      qt.text = ""
      $scope.questionTranslations.push(qt)
    qt

  $scope.save = () ->
    qt = new QuestionTranslation()
    qt.question_translations = $scope.questionTranslations
    qt.$batch_update({},
      (data, headers) ->
        getQuestions()
      (result, headers) ->
        alert(result.data.errors)
    )

  getQuestions = () ->
    if $stateParams.question_set_id
      $scope.questionTranslations = QuestionTranslation.query({
        'language': $scope.language,
        'question_set_id': $stateParams.question_set_id
      })
      $scope.questions = Question.query({'question_set_id': $stateParams.question_set_id})
    else if $stateParams.instrument_id
      $scope.questionTranslations = QuestionTranslation.query({
        'language': $scope.language,
        'instrument_id': $stateParams.instrument_id
      })
      $scope.questions = Questions.query({'instrument_id': $stateParams.instrument_id})
    else
      $scope.questionTranslations = QuestionTranslation.query({'language': $scope.language})
      $scope.questions = Questions.query({})

  $scope.language = $stateParams.language
  getQuestions()

]

App.controller 'InstructionTranslationsCtrl', ['$scope', '$stateParams', 'Setting',
'Instruction', 'InstructionTranslation', ($scope, $stateParams, Setting, Instruction,
InstructionTranslation) ->
  $scope.language = $stateParams.language
  $scope.instructions = Instruction.query({})
  $scope.instruction_translations = InstructionTranslation.query({'language': $scope.language})

  $scope.translation_for = (instruction) ->
    inst = _.findWhere($scope.instruction_translations, {instruction_id: instruction.id})
    if inst == undefined
      inst = new InstructionTranslation()
      inst.language = $scope.language
      inst.instruction_id = instruction.id
      inst.text = ""
      $scope.instruction_translations.push(inst)
    inst

  $scope.save = () ->
    angular.forEach $scope.instruction_translations, (inst, index) ->
      if inst.id
        inst.$update({})
      else if inst.text != ""
        inst.$save({})

]
