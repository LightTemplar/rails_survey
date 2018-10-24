App.controller 'QuestionBackTranslationsCtrl', ['$scope', '$stateParams', '$state', 'Setting',
'QuestionTranslation', 'QuestionBackTranslation', ($scope, $stateParams, $state, Setting,
QuestionTranslation, QuestionBackTranslation) ->
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
    $scope.questionBackTranslations = QuestionBackTranslation.query({
      'language': $stateParams.language,
      'question_set_id': $stateParams.question_set_id
      'question_translation_id': $stateParams.question_translation_id
    })
  else if $stateParams.question_set_id && $stateParams.language
    $scope.questionTranslations = QuestionTranslation.query({
      'language': $stateParams.language,
      'question_set_id': $stateParams.question_set_id
    })
    $scope.questionBackTranslations = QuestionBackTranslation.query({
      'language': $stateParams.language,
      'question_set_id': $stateParams.question_set_id
    })
  else if $stateParams.instrument_id && $stateParams.language
    $scope.questionTranslations = QuestionTranslation.query({
      'language': $stateParams.language,
      'instrument_id': $stateParams.instrument_id
    })
    $scope.questionBackTranslations = QuestionBackTranslation.query({
      'language': $stateParams.language,
      'instrument_id': $stateParams.instrument_id
    })
  else if $stateParams.language
    $scope.questionTranslations = QuestionTranslation.query({'language': $stateParams.language})
    $scope.questionBackTranslations = QuestionBackTranslation.query({'language': $stateParams.language})

  $scope.updateLanguage = () ->
    $state.go('questionBackTranslations', {
      language: $scope.language,
      instrument_id: $stateParams.instrument_id,
      question_set_id: $stateParams.question_set_id
    })

  $scope.backTranslationFor = (questionTranslation) ->
    qbt = _.findWhere($scope.questionBackTranslations, {backtranslatable_id: questionTranslation.id})
    if qbt == undefined
      qbt = new QuestionBackTranslation()
      qbt.backtranslatable_id = questionTranslation.id
      qbt.backtranslatable_type = 'QuestionTranslation'
      qbt.language = $scope.language
      qbt.text = ""
      $scope.questionBackTranslations.push(qbt)
    qbt

  $scope.save = () ->
    qbt = new QuestionBackTranslation()
    qbt.question_back_translations = $scope.questionBackTranslations
    qbt.$batch_update({},
      (data, headers) ->
        $state.reload()
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'OptionBackTranslationsCtrl', ['$scope', '$stateParams', '$state', 'Setting',
'OptionTranslation', 'OptionBackTranslation', ($scope, $stateParams, $state, Setting,
OptionTranslation, OptionBackTranslation) ->
  $scope.option_set_id = $stateParams.option_set_id
  $scope.language = $stateParams.language
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0, 1)
    $scope.languages = $scope.settings.languages
  )

  if $stateParams.option_set_id && $stateParams.option_id && $stateParams.language
    $scope.optionTranslations = OptionTranslation.query({
      'language': $stateParams.language,
      'option_set_id': $stateParams.option_set_id
      'option_id': $stateParams.option_id
    })
    $scope.optionBackTranslations = OptionBackTranslation.query({
      'language': $stateParams.language,
      'option_set_id': $stateParams.option_set_id
      'option_translation_id': $stateParams.option_translation_id
    })
  else if $stateParams.option_set_id && $stateParams.language
    $scope.optionTranslations = OptionTranslation.query({
      'language': $stateParams.language,
      'option_set_id': $stateParams.option_set_id
    })
    $scope.optionBackTranslations = OptionBackTranslation.query({
      'language': $stateParams.language,
      'option_set_id': $stateParams.option_set_id
    })
  else if $stateParams.instrument_id && $stateParams.language
    $scope.optionTranslations = OptionTranslation.query({
      'language': $stateParams.language,
      'instrument_id': $stateParams.instrument_id
    })
    $scope.optionBackTranslations = OptionBackTranslation.query({
      'language': $stateParams.language,
      'instrument_id': $stateParams.instrument_id
    })
  else if $stateParams.language
    $scope.optionTranslations = OptionTranslation.query({'language': $stateParams.language})
    $scope.optionBackTranslations = OptionBackTranslation.query({'language': $stateParams.language})

  $scope.updateLanguage = () ->
    $state.go('optionBackTranslations', {
      language: $scope.language,
      instrument_id: $stateParams.instrument_id,
      option_set_id: $stateParams.option_set_id
    })

  $scope.backTranslationFor = (optionTranslation) ->
    qbt = _.findWhere($scope.optionBackTranslations, {backtranslatable_id: optionTranslation.id})
    if qbt == undefined
      qbt = new OptionBackTranslation()
      qbt.backtranslatable_id = optionTranslation.id
      qbt.backtranslatable_type = 'OptionTranslation'
      qbt.language = $scope.language
      qbt.text = ""
      $scope.optionBackTranslations.push(qbt)
    qbt

  $scope.save = () ->
    qbt = new OptionBackTranslation()
    qbt.option_back_translations = $scope.optionBackTranslations
    qbt.$batch_update({},
      (data, headers) ->
        $state.reload()
      (result, headers) ->
        alert(result.data.errors)
    )

]
