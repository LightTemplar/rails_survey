App.controller 'OptionsCtrl', ['$scope', 'Option', '$routeParams', ($scope, Option, $routeParams) ->

  $scope.options = Option.query({"option_set_id": $routeParams.id})

  $scope.newOption = () ->
    option = new Option()
    $scope.currentOption = option
    $scope.options.push(option)

  $scope.editOption = (option) ->
    $scope.currentOption = option

  $scope.saveOption = (option) ->
    option.option_set_id = $scope.optionSet.id
    if $scope.currentOption.id
      $scope.currentOption.$update({} ,
        (data, headers) -> ,
        (result, headers) ->
      )
    else
      $scope.currentOption.$save({} ,
        (data, headers) -> ,
        (result, headers) ->
      )
    $scope.currentOption = null

  $scope.deleteOption = () ->
    if confirm('Are you sure you want to delete this option?')
      if $scope.currentOption.id
        $scope.currentOption.$delete({} ,
          (data, headers) ->
            index = $scope.options.indexOf($scope.currentOption)
            $scope.options.splice(index,1)
            $scope.currentOption = null
          (result, headers) ->
        )

]
