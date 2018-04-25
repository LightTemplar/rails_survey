App.controller 'LanguageTranslationsCtrl', ['$scope', '$stateParams', '$location', 'Setting',
($scope, $stateParams, $location, Setting) ->
  $scope.question_set_id = $stateParams.question_set_id
  $scope.option_set_id = $stateParams.option_set_id
  $scope.instruction_id = $stateParams.instruction_id
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0,1)
    $scope.languages = $scope.settings.languages
  )

]

App.controller 'OptionTranslationsCtrl', ['$scope', '$stateParams', 'Setting',
'Options', 'OptionTranslation', 'Option', ($scope, $stateParams, Setting,
Options, OptionTranslation, Option) ->

  getOptions = () ->
    if $stateParams.option_set_id
      $scope.options = Option.query({'option_set_id': $stateParams.option_set_id})
      $scope.optionTranslations = OptionTranslation.query({
        'language': $scope.language, 'option_set_id': $stateParams.option_set_id
        })
    else
      $scope.options = Options.query({})
      $scope.optionTranslations = OptionTranslation.query({'language': $scope.language})

  $scope.translationFor = (option) ->
    ot = _.findWhere($scope.optionTranslations, {option_id: option.id})
    if ot == undefined
      ot = new OptionTranslation()
      ot.language = $scope.language
      ot.option_id = option.id
      ot.text = ""
      $scope.optionTranslations.push(ot)
    ot

  $scope.save = () ->
    ot = new OptionTranslation()
    ot.option_translations = $scope.optionTranslations
    ot.$batch_update({},
      (data, headers) ->
        getOptions()
      (result, headers) ->
        alert(result.data.errors)
    )

  $scope.language = $stateParams.language
  getOptions()

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

  getInstructions = () ->
    $scope.instructions = []
    if $stateParams.instruction_id
      instruction = Instruction.get({'id': $stateParams.instruction_id}, ->
        $scope.instructions.push(instruction)
      )
      $scope.instructionTranslations = InstructionTranslation.query({
        'language': $scope.language,
        'instruction_id': $stateParams.instruction_id
      })
    else
      $scope.instructions = Instruction.query({})
      $scope.instructionTranslations = InstructionTranslation.query({'language': $scope.language})

  $scope.translationFor = (instruction) ->
    inst = _.findWhere($scope.instructionTranslations, {instruction_id: instruction.id})
    if inst == undefined
      inst = new InstructionTranslation()
      inst.language = $scope.language
      inst.instruction_id = instruction.id
      inst.text = ""
      $scope.instructionTranslations.push(inst)
    inst

  $scope.save = () ->
    it = new InstructionTranslation()
    it.instruction_translations = $scope.instructionTranslations
    it.$batch_update({},
      (data, headers) ->
        getInstructions()
      (result, headers) ->
        alert(result.data.errors)
    )

  $scope.language = $stateParams.language
  getInstructions()

]
