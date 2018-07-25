App.controller 'ValidationsCtrl', ['$scope', '$location', 'Validation', ($scope, $location, Validation) ->

  $scope.createValidation = () ->
    setNewValidation(new Validation(), true)

  $scope.cancelNewValidation = () ->
    setNewValidation(null, false)

  $scope.saveValidation = () ->
    $scope.newValidation.$save({} ,
      (data, headers) ->
        $scope.newValidation = data
        $scope.validations.push($scope.newValidation)
        $location.path '/validations/' + data.id
      (result, headers) ->
    )
    $scope.cancelNewValidation()

  $scope.deleteValidation = (validation) ->
    if confirm('Are you sure you want to delete ' + validation.title + '?')
      if validation.id
        validation.$delete({} ,
          (data, headers) ->
            $scope.validations.splice($scope.validations.indexOf(validation), 1)
          (result, headers) ->
            alert(result.data.errors)
        )

  setNewValidation = (validation, status) ->
    $scope.newValidation = validation
    $scope.showNewValidation = status

  setNewValidation(new Validation(), false)
  $scope.validations = Validation.query({})

]

App.controller 'ShowValidationCtrl', ['$scope', '$stateParams', '$state', 'Validation', 'Setting', 'Questions',
 ($scope, $stateParams, $state, Validation, Setting, Questions) ->

  $scope.toolBar = [
      ['justifyLeft', 'justifyCenter', 'justifyRight'],
      ['bold', 'italics', 'underline', 'ul', 'ol', 'clear'],
      ['html']
  ]

  $scope.settings = Setting.get({}, ->
     $scope.validationTypes = $scope.settings.validation_types
     $scope.relationalOperators = $scope.settings.relational_operators
  )

  questions = Questions.query({}, -> $scope.questionIdentifiers = _.compact(_.map(questions, (q) ->
    if q.question_type == 'INTEGER' || q.question_type == 'DECIMAL'
      q.question_identifier
  )))

  $scope.updateValidation = () ->
    if $scope.validation.id
      $scope.validation.$update({} ,
        (data, headers) ->
          $state.go('validations')
        (result, headers) ->
          alert(result.data.errors)
      )

  if $scope.validations and $stateParams.id
    $scope.validation = _.first(_.filter($scope.validations, (qs) -> qs.id == $stateParams.id))
  else if $stateParams.id and not $scope.validations
    $scope.validation = Validation.get({'id': $stateParams.id})

]
