App.controller 'InstrumentQuestionSetsCtrl', ['$scope', '_', '$stateParams', '$location', '$state',
'InstrumentQuestionSet', 'QuestionSet',
($scope, _, $stateParams, $location, $state, InstrumentQuestionSet, QuestionSet) ->

  $scope.showQuestionSets = false
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.instrumentQuestionSets = InstrumentQuestionSet.query({
    "project_id": $scope.project_id,
    "instrument_id": $scope.instrument_id
  }, ->
    $scope.existingQuestionSetIds = _.map($scope.instrumentQuestionSets, (iqs) -> iqs.question_set_id)
  )
  $scope.questionSets = QuestionSet.query({}, ->
    toggleCheckboxes()
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
    toggleCheckboxes() # TODO Doesn't update UI

  $scope.saveSelectedSets = () ->
    $scope.showQuestionSets = false
    originalQuestionSetIds = _.map($scope.instrumentQuestionSets, (iqs) -> iqs.question_set_id)
    addedQuestionSetIds = _.difference($scope.existingQuestionSetIds, originalQuestionSetIds)
    deletedQuestionSetIds = _.difference(originalQuestionSetIds, $scope.existingQuestionSetIds)
    angular.forEach addedQuestionSetIds, (questionSetId, index) ->
      iqs = new InstrumentQuestionSet()
      iqs = addRouteParameters(iqs)
      iqs.question_set_id = questionSetId
      qs = questionSetById(questionSetId)
      iqs.question_set_title = qs.title
      iqs.$save({},
        (data, headers) ->
          # TODO Doesn't update UI
          # $scope.instrumentQuestionSets.push(iqs)
        (result, headers) ->
      )
      $location.path '/projects/' + $scope.project_id + '/instruments/' +
      $scope.instrument_id + '/instrument_question_sets'
      $state.reload()
    angular.forEach deletedQuestionSetIds, (qsi, index) ->
      iqs = _.filter($scope.instrumentQuestionSets, (iqs) -> iqs.question_set_id == qsi)[0]
      iqs = addRouteParameters(iqs)
      iqs.$delete({},
        (data, headers) ->
          iqs_index = $scope.instrumentQuestionSets.indexOf(iqs)
          $scope.instrumentQuestionSets.splice(iqs_index, 1)
        (result, headers) ->
      )

  addRouteParameters = (obj) ->
    obj.project_id = $scope.project_id
    obj.instrument_id = $scope.instrument_id
    return obj

  toggleCheckboxes = () ->
    angular.forEach $scope.questionSets, (questionSet, index) ->
      if _.contains($scope.existingQuestionSetIds, questionSet.id)
        questionSet.selected = true
      else
        questionSet.selected = false

  questionSetById = (questionSetId) ->
    questionSet = _.first(_.filter($scope.questionSets, (qs) -> qs.id == questionSetId))
    return questionSet

]
