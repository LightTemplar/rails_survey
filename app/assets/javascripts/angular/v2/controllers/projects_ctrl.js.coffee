App.controller 'ProjectsCtrl', ['$scope', '$state', 'Project', ($scope, $state, Project) ->
  $scope.baseUrl = ''
  if _base_url != '/'
    $scope.baseUrl = _base_url

  $scope.projects = Project.query({})

]

App.controller 'ShowProjectCtrl', ['$scope', '$stateParams', 'Project',
'Instrument', 'Setting', ($scope, $stateParams, Project, Instrument, Setting) ->

  $scope.showInstruments = true
  $scope.project = Project.get({'id': $stateParams.id})
  $scope.instruments = Instrument.query({'project_id': $stateParams.id})
  $scope.settings = Setting.get({}, ->
    $scope.languages = $scope.settings.languages
  )

  $scope.newInstrument = () ->
    $scope.showInstruments = false
    $scope.instrument = new Instrument()
    $scope.instrument.project_id = $stateParams.id

  $scope.editInstrument = (instrument) ->
    $scope.showInstruments = false
    $scope.instrument = instrument

  $scope.saveInstrument = (instrument) ->
    if instrument.id
      instrument.$update({},
        (data, headers) ->
          $scope.showInstruments = true
          updated = _.findWhere($scope.instruments, {id: data.id})
          updated = data
        (result, headers) ->
          alert(result.data.errors)
      )
    else
      instrument.$save({},
        (data, headers) ->
          $scope.showInstruments = true
          $scope.instruments.push(data)
        (result, headers) ->
          alert(result.data.errors)
      )

  $scope.deleteInstrument = (instrument) ->
    if confirm('Are you sure you want to delete ' + instrument.title + '?')
      if instrument.id
        instrument.$delete({} ,
          (data, headers) ->
            index = $scope.instruments.indexOf(instrument)
            $scope.instruments.splice(index, 1)
          (result, headers) ->
            alert(result.data.errors)
        )

]

App.controller 'ImportInstrumentCtrl', ['$scope', '$stateParams', 'Project', '$fileUploader',
($scope, $stateParams, Project, $fileUploader) ->
  $scope.project = Project.get({'id': $stateParams.id})

  uploader = $scope.uploader = $fileUploader.create({
    scope: $scope,
    url: '/api/v2/projects/' + $stateParams.id + '/import_instrument',
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
