App.controller 'OptionTranslationsCtrl', ['$scope', '$stateParams', '$state', 'Setting',
'Options', 'OptionTranslation', 'Option', ($scope, $stateParams, $state, Setting,
Options, OptionTranslation, Option) ->
  $scope.option_set_id = $stateParams.option_set_id
  $scope.language = $stateParams.language
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0, 1)
    $scope.languages = $scope.settings.languages
  )

  if $stateParams.option_set_id && $stateParams.language
    $scope.options = Option.query({'option_set_id': $stateParams.option_set_id})
    $scope.optionTranslations = OptionTranslation.query({
      'language': $stateParams.language, 'option_set_id': $stateParams.option_set_id
    })
  else if $stateParams.language
    $scope.options = Options.query({})
    $scope.optionTranslations = OptionTranslation.query({'language': $stateParams.language})

  $scope.updateLanguage = () ->
    $state.go('optionTranslations', {
      language: $scope.language,
      option_set_id: $stateParams.option_set_id
    })

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
        $state.reload()
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'QuestionTranslationsCtrl', ['$scope', '$stateParams', '$state', 'Setting',
'Questions', 'QuestionTranslation', 'Question', ($scope, $stateParams, $state, Setting,
Questions, QuestionTranslation, Question) ->
  $scope.toolBar = [
    ['justifyLeft', 'justifyCenter', 'justifyRight'],
    ['bold', 'italics', 'underline', 'ul', 'ol', 'clear'],
    ['html', 'wordcount', 'charcount']
  ]
  $scope.question_set_id = $stateParams.question_set_id
  $scope.language = $stateParams.language
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0, 1)
    $scope.languages = $scope.settings.languages
  )

  if $stateParams.question_set_id && $stateParams.question_id && $stateParams.language
    $scope.questionTranslations = QuestionTranslation.query({
      'language': $stateParams.language,
      'question_set_id': $stateParams.question_set_id
      'question_id': $stateParams.question_id
    })
    $scope.questions = []
    question = Question.get({
      'question_set_id': $stateParams.question_set_id,
      'id': $stateParams.question_id
    }, -> $scope.questions.push(question))
  else if $stateParams.question_set_id && $stateParams.language
    $scope.questionTranslations = QuestionTranslation.query({
      'language': $stateParams.language,
      'question_set_id': $stateParams.question_set_id
    })
    $scope.questions = Question.query({'question_set_id': $stateParams.question_set_id})
  else if $stateParams.instrument_id && $stateParams.language
    $scope.questionTranslations = QuestionTranslation.query({
      'language': $stateParams.language,
      'instrument_id': $stateParams.instrument_id
    })
    $scope.questions = Questions.query({'instrument_id': $stateParams.instrument_id})
  else if $stateParams.language
    $scope.questionTranslations = QuestionTranslation.query({'language': $stateParams.language})
    $scope.questions = Questions.query({})

  $scope.updateLanguage = () ->
    $state.go('questionTranslations', {
      language: $scope.language,
      instrument_id: $stateParams.instrument_id
      question_set_id: $stateParams.question_set_id
    })

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
        $state.reload()
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'InstructionTranslationsCtrl', ['$scope', '$stateParams', '$state', 'Setting', 'Instruction',
'InstructionTranslation', ($scope, $stateParams, $state, Setting, Instruction, InstructionTranslation) ->
  $scope.toolBar = [
    ['justifyLeft', 'justifyCenter', 'justifyRight'],
    ['bold', 'italics', 'underline', 'ul', 'ol', 'clear'],
    ['html', 'wordcount', 'charcount']
  ]
  $scope.instruction_id = $stateParams.instruction_id
  $scope.language = $stateParams.language
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0, 1)
    $scope.languages = $scope.settings.languages
  )

  $scope.instructions = []
  if $stateParams.instruction_id && $stateParams.language
    instruction = Instruction.get({'id': $stateParams.instruction_id}, ->
      $scope.instructions.push(instruction)
    )
    $scope.instructionTranslations = InstructionTranslation.query({
      'language': $stateParams.language,
      'instruction_id': $stateParams.instruction_id
    })
  else if $stateParams.language
    $scope.instructions = Instruction.query({})
    $scope.instructionTranslations = InstructionTranslation.query({'language': $stateParams.language})

  $scope.updateLanguage = () ->
    $state.go('instructionTranslations', {
      language: $scope.language,
      instruction_id: $stateParams.instruction_id
    })

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
        $state.reload()
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'ValidationTranslationsCtrl', ['$scope', '$stateParams', '$state', 'Setting', 'Validation',
'ValidationTranslation', ($scope, $stateParams, $state, Setting, Validation, ValidationTranslation) ->
  $scope.toolBar = [
    ['justifyLeft', 'justifyCenter', 'justifyRight'],
    ['bold', 'italics', 'underline', 'ul', 'ol', 'clear'],
    ['html']
  ]

  $scope.validation_id = $stateParams.validation_id
  $scope.language = $stateParams.language
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0, 1)
    $scope.languages = $scope.settings.languages
  )

  $scope.validations = []
  if $stateParams.validation_id && $stateParams.language
    validation = Validation.get({'id': $stateParams.validation_id}, ->
      $scope.validations.push(validation)
    )
    $scope.validationTranslations = ValidationTranslation.query({
      'language': $stateParams.language,
      'validation_id': $stateParams.validation_id
    })
  else if $stateParams.language
    $scope.validations = Validation.query({})
    $scope.validationTranslations = ValidationTranslation.query({'language': $stateParams.language})

  $scope.updateLanguage = () ->
    $state.go('validationTranslations', {
      language: $scope.language,
      validation_id: $stateParams.validation_id
    })

  $scope.translationFor = (validation) ->
    inst = _.findWhere($scope.validationTranslations, {validation_id: validation.id})
    if inst == undefined
      inst = new ValidationTranslation()
      inst.language = $scope.language
      inst.validation_id = validation.id
      inst.text = ""
      $scope.validationTranslations.push(inst)
    inst

  $scope.save = () ->
    it = new ValidationTranslation()
    it.validation_translations = $scope.validationTranslations
    it.$batch_update({},
      (data, headers) ->
        $state.reload()
      (result, headers) ->
        alert(result.data.errors)
    )

]
