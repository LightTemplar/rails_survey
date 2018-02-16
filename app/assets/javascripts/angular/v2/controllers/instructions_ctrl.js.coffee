App.controller 'InstructionsCtrl', ['$scope', '$location', 'Instruction', ($scope, $location, Instruction) ->

  $scope.createInstruction = () ->
    setNewInstruction(new Instruction(), true)

  $scope.cancelNewInstruction = () ->
    setNewInstruction(null, false)

  $scope.saveInstruction = () ->
    $scope.newInstruction.$save({} ,
      (data, headers) ->
        $scope.newInstruction = data
        $scope.instructions.push($scope.newInstruction)
        $location.path '/instructions/' + data.id
      (result, headers) ->
    )
    $scope.cancelNewInstruction()

  $scope.deleteInstruction = (instruction) ->
    if confirm('Are you sure you want to delete ' + instruction.title + '?')
      if instruction.id
        instruction.$delete({} ,
          (data, headers) ->
            $scope.instructions.splice($scope.instructions.indexOf(instruction), 1)
          (result, headers) ->
            alert(result.data.errors)
        )

  setNewInstruction = (instruction, status) ->
    $scope.newInstruction = instruction
    $scope.showNewInstruction = status

  setNewInstruction(new Instruction(), false)
  $scope.instructions = Instruction.query({})

]

App.controller 'ShowInstructionCtrl', ['$scope', '$stateParams', '$state', 'Instruction',
 ($scope, $stateParams, $state, Instruction) ->

  $scope.toolBar = [
      ['justifyLeft', 'justifyCenter', 'justifyRight'],
      ['bold', 'italics', 'underline', 'ul', 'ol', 'clear'],
      ['html']
  ]

  $scope.updateInstruction = () ->
    if $scope.instruction.id
      $scope.instruction.$update({} ,
        (data, headers) ->
          $state.go('instructions')
        (result, headers) ->
          alert(result.data.errors)
      )

  if $scope.instructions and $stateParams.id
    $scope.instruction = _.first(_.filter($scope.instructions, (qs) -> qs.id == $stateParams.id))
  else if $stateParams.id and not $scope.instructions
    $scope.instruction = Instruction.get({'id': $stateParams.id})

]
