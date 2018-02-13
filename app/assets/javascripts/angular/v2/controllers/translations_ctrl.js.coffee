App.controller 'LanguageTranslationsCtrl', ['$scope', '$stateParams', '$location', 'Setting',
($scope, $stateParams, $location, Setting) ->
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0,1)
    $scope.languages = $scope.settings.languages
  )

  $scope.languageSelected = (language) ->
    if $stateParams.question_set_id
      $location.path('/question_translations/' + language).search({
        question_set_id: $stateParams.question_set_id
      })
    else
      $location.path('/question_translations/' + language)

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
    angular.forEach $scope.questionTranslations, (qt, index) ->
      if qt.id
        qt.$update({},
          (data, headers) ->
            getQuestions()
          (result, headers) ->
            getQuestions()
        )
      else if qt.text != ""
        qt.$save({},
          (data, headers) ->
            getQuestions()
          (result, headers) ->
            getQuestions()
        )

  getQuestions = () ->
    if $stateParams.question_set_id
      $scope.questions = Question.query({'question_set_id': $stateParams.question_set_id})
      $scope.questionTranslations = QuestionTranslation.query({'language': $scope.language})
    else
      $scope.questions = Questions.query({}) # All the questions
      $scope.questionTranslations = QuestionTranslation.query({'language': $scope.language})

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
