App.controller 'OptionsCtrl', ['$scope', 'Option', '$stateParams', '$location',
($scope, Option, $stateParams, $location) ->

  $scope.options = Option.query({"option_set_id": $stateParams.id})

  $scope.sortableOptions = {
    cursor: 'move',
    handle: '.moveOption',
    axis: 'y',
    stop: (e, ui) ->
      angular.forEach $scope.options, (option, index) ->
        option.number_in_question = index
        option.$update({})
  }

  $scope.newOption = () ->
    option = new Option()
    option.number_in_question = $scope.options.length
    $scope.currentOption = option
    $scope.options.push(option)

  $scope.editOption = (option) ->
    if $scope.currentOption == option
      $scope.currentOption = null
    else
      $scope.currentOption = option

  $scope.saveOption = (option) ->
    option.option_set_id = $scope.optionSet.id
    if $scope.currentOption.id
      $scope.currentOption.$update({} ,
        (data, headers) -> ,
        (result, headers) ->
          alert(result.data.errors)
      )
    else
      $scope.currentOption.$save({} ,
        (data, headers) -> ,
        (result, headers) ->
          alert(result.data.errors)
      )
    $scope.currentOption = null

  $scope.deleteOption = (option) ->
    if confirm('Are you sure you want to delete ' + option.text + '?')
      if option.id
        option.$delete({} ,
          (data, headers) ->
            index = $scope.options.indexOf(option)
            $scope.options.splice(index,1)
          (result, headers) ->
        )

  $scope.back = () ->
    $location.path '/option_sets/'

]
