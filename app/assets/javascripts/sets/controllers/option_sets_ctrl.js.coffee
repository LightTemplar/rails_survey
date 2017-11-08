App.controller 'OptionSetsCtrl', ['$scope', '$location', 'OptionSet', ($scope, $location, OptionSet) ->
  $scope.createOptionSet = () ->
    setNewOption(new OptionSet(), true)

  $scope.cancelNewOptionSet = () ->
    setNewOption(null, false)

  $scope.saveOptionSet = () ->
    $scope.newOptionSet.$save({} ,
      (data, headers) ->
        $scope.optionSets.push(data)
        $location.path '/option_sets/' + data.id
      (result, headers) ->
    )
    $scope.cancelNewOptionSet()

  setNewOption = (optionSet, status) ->
    $scope.newOptionSet = optionSet
    $scope.showNewOptionSet = status

  setNewOption(new OptionSet(), false)
  $scope.optionSets = OptionSet.query({})

]

App.controller 'ShowOptionSetCtrl', ['$scope', '$routeParams', '$location', 'OptionSet', 'Option',
 ($scope, $routeParams, $location, OptionSet, Option) ->

  $scope.updateOptionSet = () ->
    if $scope.optionSet.id
      $scope.optionSet.$update({} ,
        (data, headers) ->
        (result, headers) ->
      )

  $scope.deleteOptionSet = () ->
    if confirm('Are you sure you want to delete this option set?')
      if $scope.optionSet.id
        $scope.optionSet.$delete({} ,
          (data, headers) ->
            $location.path '/option_sets'
          (result, headers) ->
        )

  if $scope.optionSets and $routeParams.id
    $scope.optionSet = _.first(_.filter($scope.optionSets, (qs) -> qs.id == $routeParams.id))
  else if $routeParams.id and not $scope.optionSets
    $scope.optionSet = OptionSet.get({'id': $routeParams.id})

  if $routeParams.id
    $scope.options = Option.query({"option_set_id": $routeParams.id})

]
