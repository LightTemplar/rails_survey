App.controller 'InstrumentTranslationsCtrl', ['$scope', '$stateParams', 'Setting',
'InstrumentTranslation', 'Instrument', ($scope, $stateParams, Setting,
InstrumentTranslation, Instrument) ->

  $scope.showInstrumentTranslations = true
  $scope.project_id = $stateParams.project_id
  $scope.instrumentTranslations = InstrumentTranslation.query({
    'project_id': $stateParams.project_id,
    'instrument_id': $stateParams.instrument_id
  })
  $scope.settings = Setting.get({}, ->
    $scope.languages = $scope.settings.languages
  )
  $scope.instrument = Instrument.get({
    'project_id': $stateParams.project_id,
    'id': $stateParams.instrument_id
  })

  $scope.languageName = (code) ->
    lang = ""
    angular.forEach $scope.languages, (language, index) ->
      if language[1] == code
        lang = language[0]
    lang

  $scope.newInstrumentTranslation = () ->
    $scope.showInstrumentTranslations = false
    $scope.instrumentTranslation = new InstrumentTranslation()

  $scope.saveInstrumentTranslation = (instrumentTranslation) ->
    instrumentTranslation.project_id = $stateParams.project_id
    instrumentTranslation.instrument_id = $stateParams.instrument_id
    if instrumentTranslation.id
      instrumentTranslation.$update({},
        (data, headers) ->
          $scope.showInstrumentTranslations = true
          updated = _.findWhere($scope.instrumentTranslations, {id: data.id})
          updated = data
        (result, headers) ->
          alert(result.data.errors)
      )
    else
      instrumentTranslation.$save({},
        (data, headers) ->
          $scope.showInstrumentTranslations = true
          $scope.instrumentTranslations.push(data)
        (result, headers) ->
          alert(result.data.errors)
      )

  $scope.deleteInstrumentTranslation = (translation) ->
    translation.project_id = $stateParams.project_id
    translation.instrument_id = $stateParams.instrument_id
    if confirm('Are you sure you want to delete ' + translation.title + '?')
      if translation.id
        translation.$delete({} ,
          (data, headers) ->
            index = $scope.instrumentTranslations.indexOf(translation)
            $scope.instrumentTranslations.splice(index, 1)
          (result, headers) ->
            alert(result.data.errors)
        )

]

App.controller 'SectionTranslationsCtrl', ['$scope', '$stateParams', 'Setting', 'SectionTranslation',
'Section', ($scope, $stateParams, Setting, SectionTranslation, Section) ->
  $scope.sections = Section.query({
    'project_id': $stateParams.project_id,
    'instrument_id': $stateParams.instrument_id
  })

  $scope.settings = Setting.get({}, ->
    $scope.languages = $scope.settings.languages
  )

  $scope.sectionTranslations = SectionTranslation.query({
    'project_id': $stateParams.project_id,
    'instrument_id': $stateParams.instrument_id
  })

  $scope.translationFor = (section) ->
    sectionTranslation = _.findWhere($scope.sectionTranslations, {
      section_id: section.id, language: $scope.language
    })
    if sectionTranslation == undefined
      sectionTranslation = new SectionTranslation()
      sectionTranslation.language = $scope.language
      sectionTranslation.section_id = section.id
      sectionTranslation.text = ""
      if $scope.language != undefined
        $scope.sectionTranslations.push(sectionTranslation)
    sectionTranslation

  $scope.saveTranslations = () ->
    sectionTranslation = new SectionTranslation()
    sectionTranslation.project_id = $stateParams.project_id
    sectionTranslation.instrument_id = $stateParams.instrument_id
    sectionTranslation.section_translations = $scope.sectionTranslations
    sectionTranslation.$batch_update({},
      (data, headers) ->
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'DisplayTranslationsCtrl', ['$scope', '$stateParams', 'Setting', 'DisplayTranslation',
'Display', ($scope, $stateParams, Setting, DisplayTranslation, Display) ->
  $scope.displays = Display.query({
    'project_id': $stateParams.project_id,
    'instrument_id': $stateParams.instrument_id
  })

  $scope.settings = Setting.get({}, ->
    $scope.languages = $scope.settings.languages
  )

  $scope.displayTranslations = DisplayTranslation.query({
    'project_id': $stateParams.project_id,
    'instrument_id': $stateParams.instrument_id
  })

  $scope.translationFor = (display) ->
    displayTranslation = _.findWhere($scope.displayTranslations, {
      display_id: display.id, language: $scope.language
    })
    if displayTranslation == undefined
      displayTranslation = new DisplayTranslation()
      displayTranslation.language = $scope.language
      displayTranslation.display_id = display.id
      displayTranslation.text = ""
      if $scope.language != undefined
        $scope.displayTranslations.push(displayTranslation)
    displayTranslation

  $scope.saveTranslations = () ->
    displayTranslation = new DisplayTranslation()
    displayTranslation.project_id = $stateParams.project_id
    displayTranslation.instrument_id = $stateParams.instrument_id
    displayTranslation.display_translations = $scope.displayTranslations
    displayTranslation.$batch_update({},
      (data, headers) ->
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'ShowInstrumentTranslationsCtrl', ['$scope', '$stateParams',
'InstrumentTranslation', 'OptionSetTranslation', 'InstrumentQuestionTranslation',
($scope, $stateParams, InstrumentTranslation, OptionSetTranslation, InstrumentQuestionTranslation) ->
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.instrumentQuestions = []

  $scope.instrumentTranslation = InstrumentTranslation.get({
    'project_id': $stateParams.project_id,
    'instrument_id': $stateParams.instrument_id,
    'id': $stateParams.id
  }, ->
    $scope.language = $scope.instrumentTranslation.language
    $scope.instrumentQuestions = InstrumentQuestionTranslation.query({
      'project_id': $stateParams.project_id,
      'instrument_id': $stateParams.instrument_id,
      'language': $scope.language,
    })
  )

  $scope.optionSetTranslations = OptionSetTranslation.query({})

  $scope.questionTranslationFor = (instrumentQuestionTranslations) ->
    _.where(instrumentQuestionTranslations, {language: $scope.language})

  $scope.optionTranslationFor = (optionTranslations) ->
    _.where(optionTranslations, {language: $scope.language})

  $scope.questionBackTranslationFor = (backTranslations) ->
    _.where(backTranslations, {language: $scope.language})

  $scope.optionBackTranslationFor = (backTranslations) ->
    _.where(backTranslations, {language: $scope.language})

  $scope.selectedTranslation = (optionTranslation, optionSetId) ->
    ost = _.findWhere($scope.optionSetTranslations, {option_translation_id: optionTranslation.id, option_set_id: optionSetId})
    if ost
      return 'bg-success'
    else
      return ''

]
