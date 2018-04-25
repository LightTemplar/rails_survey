App.controller 'OptionsCtrl', ['$scope', 'Options', ($scope, Options) ->
  $scope.options = Options.query({})

  $scope.newOption = () ->
    option = new Options()
    $scope.options.unshift(option)

  $scope.updateOption = (option) ->
    if option.id
      option.$update({} ,
        (data, headers) ->
          option = data
        (result, headers) ->
          alert(result.data.errors)
      )
    else
      option.$save({} ,
        (data, headers) ->
          option = data
        (result, headers) ->
          alert(result.data.errors)
      )

  $scope.deleteOption = (option) ->
    if confirm('Are you sure you want to delete ' + option.text + '?')
      if option.id
        option.$delete({} ,
          (data, headers) ->
            $scope.options.splice($scope.options.indexOf(option), 1)
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        $scope.options.splice($scope.options.indexOf(option), 1)

]
