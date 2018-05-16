App.controller 'OptionSetsCtrl', ['$scope', '$location', 'OptionSet', '$state',
($scope, $location, OptionSet, $state) ->
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
            alert(result.data.errors)
        )

  $scope.copyOptionSet = (optionSet) ->
    optionSet.$copy({},
      (data, headers) ->
        $state.reload()
      (result, headers) ->
        alert(result.data.errors)
    )

]

App.controller 'ShowOptionSetCtrl', ['$scope', '$stateParams', '$state',
'OptionSet', 'Option', 'OptionInOptionSet', 'Instruction', ($scope, $stateParams, $state,
OptionSet, Option, OptionInOptionSet, Instruction) ->

  $scope.optionSet = OptionSet.get({'id': $stateParams.id})
  $scope.optionInOptionSets = OptionInOptionSet.query({'option_set_id': $stateParams.id})
  $scope.options = Option.query({'option_set_id': $stateParams.id})
  $scope.instructions = Instruction.query({})
  $scope.counter = 0

  $scope.updateOptionSet = () ->
    if $scope.optionSet.id
      $scope.optionSet.$update({} ,
        (data, headers) ->
          $scope.optionSet = data
        (result, headers) ->
          alert(result.data.errors)
      )

  $scope.addOption = () ->
    optionInOptionSet = new OptionInOptionSet()
    optionInOptionSet.number_in_question = $scope.optionInOptionSets.length
    optionInOptionSet.option_set_id = $stateParams.id
    $scope.optionInOptionSets.push(optionInOptionSet)

  $scope.saveOptions = () ->
    angular.forEach $scope.optionInOptionSets, (option, index) ->
      if option.id
        option.$update({},
          (data, headers) ->
            $scope.counter += 1
            reloadPage()
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        option.$save({},
          (data, headers) ->
            $scope.counter += 1
            reloadPage()
          (result, headers) ->
            alert(result.data.errors)
        )

  reloadPage = () ->
    if $scope.counter == $scope.optionInOptionSets.length
      $state.reload()

  $scope.deleteOption = (optionInOptionSet) ->
    if confirm('Are you sure you want to delete this option from the set?')
      if optionInOptionSet.id
        optionInOptionSet.$delete({},
          (data, headers) ->
            $scope.optionInOptionSets.splice($scope.optionInOptionSets.indexOf(optionInOptionSet), 1)
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        $scope.optionInOptionSets.splice($scope.optionInOptionSets.indexOf(optionInOptionSet), 1)

]
