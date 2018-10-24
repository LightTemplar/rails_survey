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

App.controller 'ImportInstrumentCtrl', ['$scope', '$fileUploader', 'Project',
($scope, $fileUploader, Project) ->
  $scope.projects = Project.query({})
  $scope.project = {}
  uploader = null

  $scope.setProject = () ->
    uploader = $scope.uploader = $fileUploader.create({
      scope: $scope,
      url: '/api/v2/projects/' + $scope.project.id + '/import_instrument',
      headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content') } ,
      isHTML5: true,
      withCredentials: true,
      alias: 'file',
      formData: [ { name: uploader } ]
    } )

    uploader.filters.push (item) ->
      type = (if uploader.isHTML5 then item.type else '/' + item.value.slice(item.value.lastIndexOf('.') + 1))
      type = '|' + type.toLowerCase().slice(type.lastIndexOf('/') + 1) + '|'
      '|csv|'.indexOf(type) isnt - 1
]

App.controller 'ResourceImportCtrl', ['$scope', '$stateParams', 'Project', '$fileUploader',
($scope, $stateParams, Project, $fileUploader) ->
  uploader = $scope.uploader = $fileUploader.create({
    scope: $scope,
    url: '/api/v2/projects/v1_v2_import',
    headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content') } ,
    isHTML5: true,
    withCredentials: true,
    alias: 'file',
    formData: [ { name: uploader } ]
  } )

  uploader.filters.push (item) ->
    type = (if uploader.isHTML5 then item.type else '/' + item.value.slice(item.value.lastIndexOf('.') + 1))
    type = '|' + type.toLowerCase().slice(type.lastIndexOf('/') + 1) + '|'
    '|csv|'.indexOf(type) isnt - 1

]
