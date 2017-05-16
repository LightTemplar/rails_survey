App.controller 'RandomizedOptionsCtrl', ['$scope', '$filter', 'RandomizedOption',  ($scope, $filter, RandomizedOption) ->
  if $scope.instrument.randomized_options? && $scope.randomizedFactor
    options = $filter('filter')($scope.instrument.randomized_options, randomized_factor_id: $scope.randomizedFactor.id, true)
    $scope.randomizedOptions = (angular.copy(option, new RandomizedOption) for option in options)
  
  $scope.addRandomizedOption = () ->
    $scope.randomizedOptions = [] if !$scope.randomizedOptions?
    option = new RandomizedOption()
    setOptionParameters(option)
    $scope.randomizedOptions.push(option)
  
  $scope.removeOption = (option) ->
    if confirm('Are you sure you want to delete this option?')
      if (option.id)
        setOptionParameters(option)
        option.$delete({} ,
          (data, headers) ->
            $scope.randomizedOptions.splice($scope.randomizedOptions.indexOf(option), 1)
          ,
          (result, headers) -> alert 'Error deleting option'
        ) 
      else
          $scope.randomizedOptions.splice($scope.randomizedOptions.indexOf(option), 1)
    
  setOptionParameters = (option) ->
    option.project_id = $scope.instrument.project_id
    option.instrument_id = $scope.instrument.id
    option.randomized_factor_id = $scope.randomizedFactor.id  
    
  $scope.$on('FACTOR_SAVED', (event, id) ->
    if (!$scope.randomizedFactor.id)
      $scope.randomizedFactor.id = id
    angular.forEach $scope.randomizedOptions, (option, index) ->
      setOptionParameters(option)
      if option.id
        option.$update({} ,
          (data, headers) ->,
          (result, headers) -> alert 'Error updating option'
        )
      else
        option.$save({} ,
          (data, headers) ->,
          (result, headers) -> alert 'Error saving option'
        )
  )
  
]