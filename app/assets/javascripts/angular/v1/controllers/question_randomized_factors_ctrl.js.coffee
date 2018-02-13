App.controller 'QuestionRandomizedFactorsCtrl', ['$scope', '$filter', 'QuestionRandomizedFactor', ($scope, $filter, QuestionRandomizedFactor) ->
  $scope.init = (project_id, instrument_id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    
  if $scope.question? 
    if $scope.question.question_randomized_factors?
      $scope.randomizedQuestionFactors = (angular.copy(factor, new QuestionRandomizedFactor) for factor in $scope.question.question_randomized_factors)
        
  $scope.addRandomizedFactor = () ->
    $scope.randomizedQuestionFactors = [] if !$scope.randomizedQuestionFactors?
    factor = new QuestionRandomizedFactor
    factor.project_id = $scope.question.project_id
    factor.instrument_id = $scope.question.instrument_id
    factor.question_id = $scope.question.id
    if $scope.randomizedQuestionFactors.length == 0
      factor.position = 1
    else 
      factor.position = $scope.randomizedQuestionFactors.length + 1
    $scope.randomizedQuestionFactors.push(factor)
    
  $scope.removeFactor = (factor) ->
    if confirm('Are you sure you want to delete this variable?')
      if (factor.id)
        factor.project_id = $scope.question.project_id
        factor.instrument_id = $scope.question.instrument_id
        factor.question_id = $scope.question.id
        factor.$delete({} ,
          (data, headers) ->
            $scope.randomizedQuestionFactors.splice($scope.randomizedQuestionFactors.indexOf(factor), 1)
          ,
          (result, headers) -> alert 'Error deleting variable'
        ) 
      else
          $scope.randomizedQuestionFactors.splice($scope.randomizedQuestionFactors.indexOf(factor), 1)
    
  $scope.$on('SAVE_QUESTION', (event, id) ->
    if ($scope.question_id == id or ! $scope.question_id)
      $scope.question_id = id
      angular.forEach $scope.randomizedQuestionFactors, (factor, index) ->
        factor.project_id = $scope.project_id
        factor.instrument_id = $scope.instrument_id
        factor.question_id = $scope.question.id
        if factor.id
          factor.$update({} ,
            (data, headers) -> , 
            (result, headers) -> alert 'Error updating factor'
          )
        else
          factor.$save({} ,
            (data, headers) -> ,
            (result, headers) -> alert 'Error saving factor'
          )
  )
          
]