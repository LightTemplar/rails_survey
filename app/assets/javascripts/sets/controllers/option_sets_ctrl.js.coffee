App.controller 'OptionSetsCtrl', ['$scope', 'OptionSet', 'Option', 'Setting',
($scope, OptionSet, Option, Setting) ->

  $scope.settings = Setting.get({})
  $scope.optionSets = OptionSet.query({})
  $scope.questions = []

  $scope.viewOptionSet = (optionSet) ->
    $scope.currentOptionSet = optionSet

  $scope.newOptionSet = () ->
    optionSet = new OptionSet()
    $scope.currentOptionSet = optionSet
    $scope.optionSets.push(optionSet)

  $scope.editOptionSet = (optionSet) ->
    $scope.currentOptionSet = optionSet

  $scope.saveOptionSet = () ->
    if $scope.currentOptionSet.id
      $scope.currentOptionSet.$update({} ,
        (data, headers) -> ,
        (result, headers) ->
      )
    else
      $scope.currentOptionSet.$save({} ,
        (data, headers) -> ,
        (result, headers) ->
      )
    $scope.currentOptionSet = null

]
