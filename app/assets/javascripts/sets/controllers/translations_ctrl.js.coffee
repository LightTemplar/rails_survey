App.controller 'LanguageTranslationsCtrl', ['$scope', 'Setting',
($scope, Setting) ->
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0,1)
    $scope.languages = $scope.settings.languages
  )

]

App.controller 'OptionTranslationsCtrl', ['$scope', '$routeParams', 'Setting',
'Options', 'OptionTranslation', ($scope, $routeParams, Setting, Options, OptionTranslation) ->
  $scope.language = $routeParams.language
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

App.controller 'QuestionTranslationsCtrl', ['$scope', '$routeParams', 'Setting',
'Questions', 'QuestionTranslation', ($scope, $routeParams, Setting, Questions,
QuestionTranslation) ->
  $scope.language = $routeParams.language
  $scope.questions = Questions.query({})
  $scope.question_translations = QuestionTranslation.query({'language': $scope.language})

  $scope.translation_for = (question) ->
    qt = _.findWhere($scope.question_translations, {question_id: question.id})
    if qt == undefined
      qt = new QuestionTranslation()
      qt.language = $scope.language
      qt.question_id = question.id
      qt.text = ""
      $scope.question_translations.push(qt)
    qt

  $scope.save = () ->
    angular.forEach $scope.question_translations, (qt, index) ->
      if qt.id
        qt.$update({})
      else if qt.text != ""
        qt.$save({})

]

App.controller 'InstructionTranslationsCtrl', ['$scope', '$routeParams', 'Setting',
'Instruction', 'InstructionTranslation', ($scope, $routeParams, Setting, Instruction,
InstructionTranslation) ->
  $scope.language = $routeParams.language
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
