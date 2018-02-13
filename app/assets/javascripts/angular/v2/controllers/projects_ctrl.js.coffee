App.controller 'ProjectCtrl', ['$scope', '$state', 'Project', ($scope, $state, Project) ->
  $scope.baseUrl = ''
  if _base_url != '/'
    $scope.baseUrl = _base_url

  $scope.projects = Project.query({})

]
