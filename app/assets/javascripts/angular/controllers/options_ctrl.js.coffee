App.controller 'OptionsCtrl', ['$scope', 'Option', '$filter', ($scope, Option, $filter) ->
  if $scope.question?
    $scope.project_id = $scope.question.project_id
    $scope.instrument_id = $scope.question.instrument_id
    $scope.question_id = $scope.question.id
    $scope.options = (angular.copy(option, new Option) for option in $scope.question.options) if $scope.question.options?
    $scope.defaultOptions = $filter('filter')($scope.options, special: false, true)

  $scope.$on('SAVE_QUESTION', (event, id) ->
    if ($scope.question_id == id or ! $scope.question_id)
      $scope.question_id = id
      angular.forEach $scope.options, (option, index) ->
        option.number_in_question = index + 1
        option.project_id = $scope.project_id
        option.instrument_id = $scope.instrument_id
        option.question_id = $scope.question_id
        if option.id
          option.$update({} ,
            (data, headers) ->,
            (result, headers) -> alert "Error updating option"
          )
        else
          option.$save({} ,
            (data, headers) ->,
            (result, headers) -> alert "Error saving option"
          )
  )

  $scope.removeOption = (option) ->
    if confirm("Are you sure you want to delete this option?")
      $scope.options.splice($scope.options.indexOf(option), 1)
      option.project_id = $scope.project_id
      option.instrument_id = $scope.instrument_id
      option.question_id = $scope.question_id
      option.$delete({} ,
        (data, headers) ->
          $scope.question.options.splice($scope.question.options.indexOf(option), 1)
          filterOptions()
        ,
        (result, headers) -> alert "Error deleting option"
      )

  $scope.addOption = ->
    $scope.options = [] if ! $scope.options?
    option = new Option
    option.project_id = $scope.project_id
    option.instrument_id = $scope.instrument_id
    option.question_id = $scope.question_id
    option.special = false
    $scope.options.push(option)
    filterOptions()

  filterOptions = () ->
    $scope.defaultOptions = $filter('filter')($scope.options, special: false, true)

]