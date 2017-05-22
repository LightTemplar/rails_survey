App.controller 'RandomizedFactorsCtrl', ['$scope', '$filter', 'Instrument', 'RandomizedFactor', ($scope, $filter, Instrument, RandomizedFactor) ->
  
  $scope.init = (project_id, instrument_id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    $scope.instrument = Instrument.get({"project_id": project_id, "id": instrument_id}, ->
      $scope.randomizedFactors = (angular.copy(factor, new RandomizedFactor) for factor in $scope.instrument.randomized_factors)
    )
  
  $scope.editFactor = (factor) ->
    if ($scope.editingFactor == factor)
      $scope.editingFactor = null
    else
      $scope.editingFactor = factor
        
  $scope.addRandomizedFactor = () ->
    $scope.randomizedFactors = [] if ! $scope.randomizedFactors?
    factor = new RandomizedFactor()
    factor.project_id = $scope.instrument.project_id
    factor.instrument_id = $scope.instrument.id
    if $scope.randomizedFactors.length == 0
      factor.position = 1
    else 
      factor.position = $scope.randomizedFactors.length + 1
    $scope.instrument.randomized_options = []
    $scope.randomizedFactors.push(factor)
    $scope.editingFactor = factor
    
  $scope.removeFactor = (factor) ->
    if confirm('Are you sure you want to delete this factor?')
      if (factor.id)
        factor.project_id = $scope.instrument.project_id
        factor.instrument_id = $scope.instrument.id
        factor.$delete({} ,
          (data, headers) ->
            $scope.randomizedFactors.splice($scope.randomizedFactors.indexOf(factor), 1)
          ,
          (result, headers) -> alert 'Error deleting variable'
        ) 
      else
          $scope.randomizedFactors.splice($scope.randomizedFactors.indexOf(factor), 1)
    
  $scope.saveFactor = (factor) ->
    factor.project_id = $scope.instrument.project_id
    factor.instrument_id = $scope.instrument.id
    if factor.id
      factor.$update({} ,
        (data, headers) ->
          $scope.$broadcast('FACTOR_SAVED', data.id)
          $scope.cancelFactor()
        , 
        (result, headers) -> alert 'Error updating factor'
      )
    else
      factor.$save({} ,
        (data, headers) ->
          $scope.$broadcast('FACTOR_SAVED', data.id)
          $scope.cancelFactor()
        ,
        (result, headers) -> alert 'Error saving factor'
      )
    
  $scope.cancelFactor = () ->
    $scope.editingFactor = null
          
]