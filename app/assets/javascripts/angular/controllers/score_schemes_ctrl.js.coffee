App.controller 'ScoreSchemesCtrl', ['$scope', 'ScoreScheme', 'Instrument', ($scope, ScoreScheme, Instrument) ->
  $scope.showIndex = true

  $scope.initialize = (project_id) ->
    $scope.project_id = project_id
    $scope.score_schemes = ScoreScheme.query({"project_id": project_id} )
    $scope.instruments = Instrument.query({"project_id": project_id} )
    if _base_url != '/'
      $scope.baseUrl = _base_url

  $scope.toggleViews = () ->
    $scope.showIndex = ! $scope.showIndex

  $scope.newScheme = () ->
    $scope.toggleViews()
    $scope.scheme = new ScoreScheme()
    $scope.scheme.project_id = $scope.project_id

  $scope.handleSelectedInstrument = (instrumentId) ->
    $scope.scheme.instrument_id = instrumentId

  $scope.createScheme = () ->
    if ! $scope.scheme.instrument_id || ! $scope.scheme.title
      alert 'Missing field'
    else
      $scope.scheme.$save({} ,
        (data, headers) ->
          $scope.score_schemes.push($scope.scheme)
          $scope.toggleViews()
        (result, headers) ->
          angular.forEach result.data.errors, (error, field) ->
            alert error
      )

]
