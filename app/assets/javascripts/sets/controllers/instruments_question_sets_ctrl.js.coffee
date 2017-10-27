App.controller 'InstrumentQuestionSetsCtrl', ['$scope', '_', 'InstrumentQuestionSet', 'QuestionSet',
($scope, _, InstrumentQuestionSet, QuestionSet) ->
  $scope.showQuestionSets = false
  $scope.init = (project_id, instrument_id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    $scope.instrumentQuestionSets = InstrumentQuestionSet.query({
      "project_id": $scope.project_id,
      "instrument_id": $scope.instrument_id
    }, ->
      $scope.existingQuestionSetIds = _.map($scope.instrumentQuestionSets, (iqs) -> iqs.question_set_id)
    )
    $scope.questionSets = QuestionSet.query({}, ->
      # Toggle checkboxes
      angular.forEach $scope.questionSets, (questionSet, index) ->
        if _.contains($scope.existingQuestionSetIds, questionSet.id)
          questionSet.selected = true
        else
          questionSet.selected = false
    )

  $scope.newInstrumentQuestionSet = () ->
    $scope.showQuestionSets = true

  $scope.selectionChanged = (questionSet) ->
    selectionIndex = $scope.existingQuestionSetIds.indexOf(questionSet.id)
    if questionSet.selected == true and selectionIndex == -1
      $scope.existingQuestionSetIds.push(questionSet.id)
    else
      if selectionIndex > -1
        $scope.existingQuestionSetIds.splice(selectionIndex, 1)

  $scope.dismissSelection = () ->
    $scope.showQuestionSets = false

  $scope.saveSelectedSets = () ->
    $scope.showQuestionSets = false
    originalQuestionSetIds = _.map($scope.instrumentQuestionSets, (iqs) -> iqs.question_set_id)
    addedQuestionSetIds = _.difference($scope.existingQuestionSetIds, originalQuestionSetIds)
    deletedQuestionSetIds = _.difference(originalQuestionSetIds, $scope.existingQuestionSetIds)
    angular.forEach addedQuestionSetIds, (questionSetId, index) ->
      iqs = new InstrumentQuestionSet()
      iqs = addRouteParameters(iqs)
      iqs.question_set_id = questionSetId
      iqs.$save({})
      $scope.instrumentQuestionSets.push(iqs)
    angular.forEach deletedQuestionSetIds, (qsi, index) ->
      iqs = _.filter($scope.instrumentQuestionSets, (iqs) -> iqs.question_set_id == qsi)[0]
      iqs = addRouteParameters(iqs)
      iqs.$delete({})
      iqs_index = $scope.instrumentQuestionSets.indexOf(iqs)
      $scope.instrumentQuestionSets.splice(iqs_index, 1)

  addRouteParameters = (obj) ->
    obj.project_id = $scope.project_id
    obj.instrument_id = $scope.instrument_id
    return obj

]
