App.controller 'PDFCtrl', ['$scope', '$stateParams', 'Instrument', 'Display', 'FileSaver',
'InstrumentQuestion', 'InstrumentOption', 'InstrumentOptionInOptionSet', 'Setting',
($scope, $stateParams, Instrument, Display, FileSaver, InstrumentQuestion, InstrumentOption,
InstrumentOptionInOptionSet, Setting) ->

  $scope.instrument_id = if $stateParams.instrument_id then $stateParams.instrument_id else $stateParams.id
  $scope.project_id = $stateParams.project_id
  $scope.instrument = Instrument.get({
    'project_id': $scope.project_id,
    'id': $scope.instrument_id
  })
  $scope.displays = Display.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })
  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })
  $scope.instrumentOptions = InstrumentOption.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })
  $scope.instrumentOptionInOptionSets = InstrumentOptionInOptionSet.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })
  $scope.settings = Setting.get({})

  $scope.singleSelectQuestionType = (questionType) ->
    questionType in ['SELECT_ONE', 'SELECT_ONE_WRITE_OTHER', 'DROP_DOWN']

  $scope.multipleSelectQuestionType = (questionType) ->
    questionType in ['SELECT_MULTIPLE', 'SELECT_MULTIPLE_WRITE_OTHER']

  $scope.otherQuestionType = (questionType) ->
    questionType in ['SELECT_ONE_WRITE_OTHER', 'SELECT_MULTIPLE_WRITE_OTHER']

  $scope.freeFormQuestionType = (questionType) ->
    questionType in ['FREE_RESPONSE']

  $scope.dateQuestionType = (questionType) ->
    questionType == 'DATE'

  $scope.monthAndYearQuestionType = (questionType) ->
    questionType == 'MONTH_AND_YEAR'

  $scope.numberQuestionType = (questionType) ->
    questionType in ['INTEGER', 'DECIMAL_NUMBER']

  $scope.questionOptions = (question) ->
    oios = _.where($scope.instrumentOptionInOptionSets, {option_set_id: question.option_set_id})
    optionIds = _.pluck(oios, 'option_id')
    options = []
    angular.forEach optionIds, (id, index) ->
      options.push(_.findWhere($scope.instrumentOptions, {id: id}))
    options

  $scope.displayQuestions = (display) ->
    _.where($scope.instrumentQuestions, {display_id: display.id})

  $scope.download = () ->
    instrument = new Instrument()
    instrument.project_id = $stateParams.project_id
    instrument.id = $scope.instrument_id
    instrument.data = document.getElementById('html-to-pdf').innerHTML
    instrument.$to_pdf({},
      (data, headers) ->
        FileSaver.saveAs(data.response, $scope.instrument.title + '.pdf')
      (result, headers) ->
        alert(result.data.errors)
    )
]
