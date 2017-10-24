App.controller 'OptionsCtrl', ['$scope', 'Option', ($scope, Option) ->

  $scope.init = (optionSet) ->
    $scope.optionSet = optionSet
    $scope.options = Option.query({"option_set_id": $scope.optionSet.id})

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

]
