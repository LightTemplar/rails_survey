App.controller 'ScoreSchemeEditorCtrl', ['$scope', '$uibModal', '$filter', 'ScoreScheme', 'ScoreUnit', 'OptionScore', ($scope, $uibModal, $filter, ScoreScheme, ScoreUnit, OptionScore) ->
  $scope.perPage = 5
  $scope.maxNumOfLinks = 10
  $scope.initialize = (project_id, score_scheme_id) ->
    $scope.project_id = project_id
    $scope.score_scheme_id = score_scheme_id
    $scope.score_scheme = ScoreScheme.get({
      'project_id': project_id,
      'id': score_scheme_id
    } , ->
      $scope.totalItems = $scope.score_scheme.score_unit_count
    )
    $scope.getScoreUnits(1)

  $scope.getScoreUnits = (pageNumber) ->
    $scope.currentPage = pageNumber
    $scope.score_units = ScoreUnit.query({
      'project_id': $scope.project_id,
      'score_scheme_id': $scope.score_scheme_id
      'page': pageNumber
    } )

  $scope.offset = () ->
    if $scope.currentPage == 1 then 0 else $scope.perPage * ($scope.currentPage - 1)

  createScoreUnit = () ->
    return new ScoreUnit(
      project_id: $scope.project_id,
      score_scheme_id: $scope.score_scheme_id,
      instrument_id: $scope.score_scheme.instrument_id
      question_ids: []
    )

  $scope.newScoreUnit = (unit = createScoreUnit()) ->
    unit.option_scores = []
    newScoreUnitModalView = openModal(unit, 'scoreUnit.html')
    newScoreUnitModalView.result.then ((scoreUnit) ->
      if scoreUnit.score_type == 'multiple_select'
        scoreUnit.option_scores = multipleOptions(scoreUnit)
      else if scoreUnit.score_type == 'range'
        scoreUnit.option_scores = rangeOptions(scoreUnit)

      selectModalView = openModal(scoreUnit)
      selectModalView.result.then ((scoreUnit) ->
        scoreUnit.$save({} ,
          (data, headers) ->
            $scope.score_units.push(scoreUnit)
            return
          (result, headers) ->
            angular.forEach result.data.errors, (error, field) ->
              alert error
        )
      ), (reason) ->
        if reason.constructor.name == 'Resource'
          $scope.newScoreUnit(reason)
        return
    ), ->
      return

  $scope.deleteScoreUnit = (unit) ->
    if confirm('Are you sure you want to delete this score unit?')
      unit.project_id = $scope.project_id
      unit.$delete({} ,
        (data) ->
          $scope.score_units.splice($scope.score_units.indexOf(unit), 1)
      ,
        (data) ->
          alert 'Failed to delete score unit'
      )

  $scope.editScoreUnit = (unit) ->
    unit.project_id = $scope.project_id
    unit.instrument_id = $scope.score_scheme.instrument_id
    unit.question_ids = []
    if unit.score_type == 'simple_search'
      unit.option_scores = OptionScore.query({
        project_id: unit.project_id,
        score_scheme_id: unit.score_scheme_id,
        score_unit_id: unit.id
      } )
    scoreUnitQuestions = ScoreUnit.questions({
      project_id: $scope.project_id,
      score_scheme_id: unit.score_scheme_id,
      id: unit.id
    } , ->
      unit.question_ids = scoreUnitQuestions.map((question) -> question.id)
    )
    editModalView = openModal(unit, 'scoreUnit.html')

    editModalView.result.then ((scoreUnit) ->
      optionScores = OptionScore.query({
        project_id: $scope.project_id,
        score_scheme_id: scoreUnit.score_scheme_id,
        score_unit_id: scoreUnit.id
      } , ->
        if scoreUnit.score_type == 'single_select'
          angular.forEach optionScores, (optionScore, index) ->
            savedOptionScore = $filter('filter')(scoreUnit.option_scores, option_id: optionScore.option_id, true)[0]
            savedOptionScoreIndex = scoreUnit.option_scores.indexOf(savedOptionScore)
            if savedOptionScoreIndex != - 1
              scoreUnit.option_scores[savedOptionScoreIndex] = optionScore
        else if scoreUnit.score_type == 'multiple_select'
          allOptions = multipleOptions(scoreUnit)
          for option, index in allOptions
            existingOption = $filter('filter')(optionScores, option_id: option.option_id, value: option.value, true)[0]
            if existingOption?
              existingOption.selected = true
              allOptions[index] = existingOption
          scoreUnit.option_scores = allOptions
        else if scoreUnit.score_type == 'range' || scoreUnit.score_type == 'multiple_select_sum'
          scoreUnit.option_scores = optionScores
      )

      secondEditModalView = openModal(scoreUnit)
      secondEditModalView.result.then ((unit) ->
        unit.$update({} ,
          (data, headers) ->
            $scope.$broadcast('UNIT_UPDATED', data.id)
          (result, headers) ->
        )
      ), (reason) ->
        if reason.constructor.name == 'Resource'
          $scope.editScoreUnit(reason)
      return
    ), ->
    return

  multipleOptions = (scoreUnit) ->
    multipleOptionScores = []
    for number in [scoreUnit.min..scoreUnit.max]
      for option in scoreUnit.option_scores
        multipleOptionScores.push({label: option.label, option_id: option.option_id, value: number} )
    multipleOptionScores

  rangeOptions = (unit) ->
    numOptions = ({label: '', value: num} for num in [unit.min..unit.max])

  openModal = (scoreUnit, file = null) ->
    if file == null
      file = getTemplate(scoreUnit)
    $uibModal.open(
      templateUrl: file,
      controller: 'ScoreUnitModalCtrl',
      size: 'lg',
      resolve: scoreUnit: -> scoreUnit
    )

  getTemplate = (scoreUnit) ->
    if scoreUnit.score_type == 'single_select'
      templateFile = 'singleSelect.html'
    else if scoreUnit.score_type == 'multiple_select'
      templateFile = 'multipleSelect.html'
    else if scoreUnit.score_type == 'multiple_select_sum'
      templateFile = 'multipleSelectSum.html'
    else if scoreUnit.score_type == 'range'
      templateFile = 'range.html'
    else if scoreUnit.score_type == 'simple_search'
      templateFile = 'simpleSearch.html'
    templateFile

]