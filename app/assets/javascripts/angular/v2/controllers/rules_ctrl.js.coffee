App.controller 'RulesCtrl', ['$scope', 'Rule', 'Setting', ($scope, Rule, Setting) ->
  $scope.rules = Rule.query({})
  $scope.settings = Setting.get({}, ->
    $scope.ruleTypes = $scope.settings.rule_types
    $scope.ruleNames = _.map($scope.ruleTypes, (ruleType) -> ruleType.constant_name)
  )

  $scope.createRule = () ->
    $scope.newRule = new Rule()
    $scope.showNewRule = true

  $scope.cancelNewRule = () ->
      $scope.newRule = null
      $scope.showNewRule = false

  $scope.saveRule = () ->
    $scope.newRule.rule_params = getRuleParams()
    $scope.newRule.$save({} ,
      (data, headers) ->
        $scope.rules.push(data)
        $scope.cancelNewRule()
      (result, headers) ->
        alert(result.data.errors)
    )

  $scope.deleteRule = (rule) ->
    if confirm('Are you sure you want to delete ' + rule.rule_type + '?')
      if rule.id
        rule.$delete({},
          (data, headers) ->
            $scope.rules.splice($scope.rules.indexOf(rule), 1)
          (result, headers) ->
            alert(result.data.errors)
        )

  getRuleParams = () ->
    switch $scope.newRule.rule_type
      when "INSTRUMENT_SURVEY_LIMIT_RULE" then JSON.stringify({ max_surveys: $scope.newRule.maxSurveys })
      when "INSTRUMENT_TIMING_RULE" then JSON.stringify({ start_time: $scope.newRule.startTime, end_time: $scope.newRule.endTime })
      when "INSTRUMENT_SURVEY_LIMIT_PER_MINUTE_RULE" then JSON.stringify({ num_surveys: $scope.newRule.numSurveys, minute_interval: $scope.newRule.minuteInterval })
      when "PARTICIPANT_TYPE_RULE" then JSON.stringify({ participant_type: $scope.newRule.participantType })
      when "INSTRUMENT_LAUNCH_RULE" then JSON.stringify({})
      when "PARTICIPANT_AGE_RULE" then JSON.stringify({ start_age: $scope.newRule.startAge, end_age: $scope.newRule.endAge })

]

App.controller 'InstrumentRulesCtrl', ['$scope', '$stateParams', 'Rule', 'InstrumentRule',
($scope, $stateParams, Rule, InstrumentRule) ->
  $scope.rules = Rule.query({})
  $scope.instrumentRules = InstrumentRule.query({
    'project_id': $stateParams.project_id,
    'instrument_id': $stateParams.instrument_id
  })

  $scope.addInstrumentRule = () ->
    $scope.newRule = new InstrumentRule()
    $scope.newRule.project_id = $stateParams.project_id
    $scope.newRule.instrument_id = $stateParams.instrument_id
    $scope.showNewRule = true

  $scope.cancelInstrumentRule = () ->
    $scope.showNewRule = false
    $scope.newRule = null

  $scope.saveInstrumentRule = () ->
    $scope.newRule.$save({},
      (data, headers) ->
        onInstrumentRuleSaved(data)
      (result, headers) ->
        alert(result.data.errors)
    )

  $scope.deleteInstrumentRule = (rule) ->
    if confirm('Are you sure you want to delete ' + rule.rule_type + '?')
      if rule.id
        rule.project_id = $stateParams.project_id
        rule.$delete({},
          (data, headers) ->
            $scope.instrumentRules.splice($scope.instrumentRules.indexOf(rule), 1)
          (result, headers) ->
            alert(result.data.errors)
        )

  onInstrumentRuleSaved = (ir) ->
    rule = _.findWhere($scope.rules, { id: ir.rule_id })
    if rule
      ir.rule_type = rule.rule_type
      ir.rule_params = rule.rule_params
    $scope.instrumentRules.push(ir)
    $scope.cancelInstrumentRule()

]
