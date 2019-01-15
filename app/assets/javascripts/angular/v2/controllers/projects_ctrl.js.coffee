App.controller 'ProjectsCtrl', ['$scope', '$state', 'Project', 'Instrument',
($scope, $state, Project, Instrument) ->
  $scope.baseUrl = ''
  if _base_url != '/'
    $scope.baseUrl = _base_url

  $scope.showInstruments = true
  $scope.showEditInstrument = false
  $scope.showNewInstrument = false
  $scope.projects = Project.query({})

  $scope.newInstrument = () ->
    $scope.showInstruments = false
    $scope.showNewInstrument = true

  $scope.editInstrument = (instrument) ->
    $scope.showInstruments = false
    $scope.showEditInstrument = true
    $scope.instrument = instrument

  $scope.deleteInstrument = (instrument) ->
    if confirm('Are you sure you want to delete ' + instrument.title + '?')
      if instrument.id
        instrumentCopy = new Instrument()
        instrumentCopy.id = instrument.id
        instrumentCopy.title = instrument.title
        instrumentCopy.project_id = instrument.project_id
        instrumentCopy.$delete({} ,
          (data, headers) ->
            $state.reload()
          (result, headers) ->
            alert(result.data.errors)
        )

]

App.controller 'NewInstrumentCtrl', ['$scope', '$state', 'Instrument', 'Setting',
($scope, $state, Instrument, Setting) ->
  $scope.instrument = new Instrument()

  $scope.settings = Setting.get({}, ->
    $scope.languages = $scope.settings.languages
  )

  $scope.saveInstrument = (instrument) ->
    instrument.$save({},
      (data, headers) ->
        $state.reload()
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'EditInstrumentCtrl', ['$scope', '$state', 'Instrument', 'Setting',
($scope, $state, Instrument, Setting) ->

  $scope.settings = Setting.get({}, ->
    $scope.languages = $scope.settings.languages
  )

  $scope.saveInstrument = (instrument) ->
    if instrument.id
      instrumentCopy = new Instrument()
      instrumentCopy.id = instrument.id
      instrumentCopy.title = instrument.title
      instrumentCopy.project_id = instrument.project_id
      instrumentCopy.published = instrument.published
      instrumentCopy.language = instrument.language
      instrumentCopy.$update({},
        (data, headers) ->
          $state.reload()
        (result, headers) ->
          alert(result.data.errors)
      )

]

App.controller 'ImportInstrumentCtrl', ['$scope', '$http', 'Project', '$state',
($scope, $http, Project, $state) ->
  $scope.projects = Project.query({})
  $scope.project = {}

  $scope.upload = () ->
    uploadUrl = '/api/v2/projects/' + $scope.project.id + '/import_instrument'
    data = new FormData
    for key of $scope.project
      data.append key, $scope.project[key]
    $http.post(uploadUrl, data,
      transformRequest: angular.indentity
      headers: 'Content-Type': undefined
    ).success((data) ->
      $state.go('/', {})
    ).error (data) ->
      alert('Upload Failed' + data)

]

App.controller 'ResourceImportCtrl', ['$scope', '$state', '$http', ($scope, $state, $http) ->
  $scope.resource = {}
  $scope.upload = () ->
    data = new FormData
    for key of $scope.resource
      data.append key, $scope.resource[key]
    $http.post('/api/v2/projects/v1_v2_import', data,
      transformRequest: angular.indentity
      headers: 'Content-Type': undefined
    ).success((data) ->
      $state.go('/', {})
    ).error (data) ->
      alert('Upload Failed' + data)

]
