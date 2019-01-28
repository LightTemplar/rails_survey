App.controller 'PDFCtrl', ['$scope', '$stateParams', 'Instrument', 'Display', 'FileSaver',
'InstrumentQuestion', 'Options', 'OptionInOptionSet', 'Setting',
($scope, $stateParams, Instrument, Display, FileSaver, InstrumentQuestion, Options,
OptionInOptionSet, Setting) ->

  $scope.instrument_id = if $stateParams.instrument_id then $stateParams.instrument_id else $stateParams.id
  $scope.project_id = $stateParams.project_id

  $scope.instrument = Instrument.get({
    'project_id': $scope.project_id,
    'id': $scope.instrument_id
  })

  $scope.settings = Setting.get({}, ->
    $scope.languages = $scope.settings.languages
  )

  $scope.download = (instrument) ->
    title = instrument.title
    instrument.project_id = $scope.project_id
    instrument.id = $scope.instrument_id
    instrument.$to_pdf({},
      (data, headers) ->
        FileSaver.saveAs(data.response, title + '.pdf')
      (result, headers) ->
        alert(result.data.errors)
    )
]
