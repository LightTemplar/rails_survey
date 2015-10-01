App.controller 'OptionsCtrl', ['$scope', '$filter', 'Option', ($scope, $filter, Option) ->
  $scope.options = []
  $scope.init = (project_id, instrument_id, question_id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    $scope.question_id = question_id
    $scope.filterQuestionOptions()

  $scope.filterQuestionOptions = ->
    if $scope.instrument_id and $scope.question_id
      $scope.options = $filter('filter')($scope.$parent.options, question_id: $scope.question_id, true)

  $scope.$on('SAVE_QUESTION', (event, id) ->
    if ($scope.question_id == id or !$scope.question_id)
      $scope.question_id = id
      angular.forEach $scope.options, (option, index) ->
        option.number_in_question = index + 1
        option.project_id = $scope.project_id
        option.instrument_id = $scope.instrument_id
        option.question_id = $scope.question_id
        if option.id
          option.$update({},
            (data, headers) -> $scope.filterQuestionOptions(),
            (result, headers) -> alert "Error updating option"
          )
        else
          option.$save({},
            (data, headers) -> $scope.filterQuestionOptions(),
            (result, headers) -> alert "Error saving option"
          )
  )
 
  $scope.$on('CANCEL_QUESTION', ->
    $scope.filterQuestionOptions()
  )

  $scope.$on('EDIT_QUESTION', (event, id) ->
    if $scope.question_id == id
      $scope.filterQuestionOptions()
  )

  $scope.removeOption = (option) ->
    if confirm("Are you sure you want to delete this option?")
      $scope.$parent.options.splice($scope.$parent.options.indexOf(option), 1)
      option.project_id = $scope.project_id
      option.instrument_id = $scope.instrument_id
      option.question_id = $scope.question_id
      option.$delete({},
        (data, headers) -> $scope.filterQuestionOptions(),
        (result, headers) -> alert "Error deleting option"
      )

  $scope.addOption = ->
    option = new Option
    option.project_id = $scope.project_id
    option.instrument_id = $scope.instrument_id
    option.question_id = $scope.question_id
    $scope.$parent.options.push(option)
    if $scope.instrument_id and $scope.question_id
      $scope.filterQuestionOptions()
    else
      $scope.options.push(option)

]