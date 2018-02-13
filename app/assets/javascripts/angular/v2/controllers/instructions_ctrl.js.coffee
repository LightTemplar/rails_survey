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

  setNewInstruction = (instruction, status) ->
    $scope.newInstruction = instruction
    $scope.showNewInstruction = status

  setNewInstruction(new Instruction(), false)
  $scope.instructions = Instruction.query({})
]

App.controller 'ShowInstructionCtrl', ['$scope', '$stateParams', '$location', 'Instruction',
 ($scope, $stateParams, $location, Instruction) ->

  $scope.updateInstruction = () ->
    if $scope.instruction.id
      $scope.instruction.$update({} ,
        (data, headers) ->
        (result, headers) ->
      )

  $scope.deleteInstruction = () ->
    if confirm('Are you sure you want to delete this instruction?')
      if $scope.instruction.id
        $scope.instruction.$delete({} ,
          (data, headers) ->
            $location.path '/instructions'
          (result, headers) ->
        )

  if $scope.instructions and $stateParams.id
    $scope.instruction = _.first(_.filter($scope.instructions, (qs) -> qs.id == $stateParams.id))
  else if $stateParams.id and not $scope.instructions
    $scope.instruction = Instruction.get({'id': $stateParams.id})

]
