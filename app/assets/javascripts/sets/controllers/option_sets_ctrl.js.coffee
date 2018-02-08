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

  $scope.deleteOptionSet = (optionSet) ->
    if confirm('Are you sure you want to delete' + optionSet.title + '?')
      if optionSet.id
        optionSet.$delete({} ,
          (data, headers) ->
            $scope.optionSets.splice($scope.optionSets.indexOf(optionSet), 1)
          (result, headers) ->
        )

]

App.controller 'ShowOptionSetCtrl', ['$scope', '$stateParams', '$location', 'OptionSet', 'Option',
 ($scope, $stateParams, $location, OptionSet, Option) ->

  $scope.updateOptionSet = () ->
    if $scope.optionSet.id
      $scope.optionSet.$update({} ,
        (data, headers) ->
        (result, headers) ->
      )

  if $scope.optionSets and $stateParams.id
    $scope.optionSet = _.first(_.filter($scope.optionSets, (qs) -> qs.id == $stateParams.id))
  else if $stateParams.id and not $scope.optionSets
    $scope.optionSet = OptionSet.get({'id': $stateParams.id})

  if $stateParams.id
    $scope.options = Option.query({"option_set_id": $stateParams.id})

]
