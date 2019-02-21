App.controller 'ShowInstrumentQuestionCtrl', ['$scope', '$stateParams',
'InstrumentQuestion', 'NextQuestion', 'MultipleSkip', 'FollowUpQuestion',
'ConditionSkip', 'LoopQuestion', ($scope, $stateParams, InstrumentQuestion,
NextQuestion, MultipleSkip, FollowUpQuestion, ConditionSkip, LoopQuestion) ->
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id

  $scope.instrumentQuestion = InstrumentQuestion.get({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'id': $scope.id
  })
  $scope.nextQuestions = NextQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })
  $scope.multipleSkips = MultipleSkip.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })
  $scope.followUpQuestions = FollowUpQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })
  $scope.conditionSkips = ConditionSkip.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })
  $scope.loopQuestions = LoopQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })

  $scope.saveTags = () ->
    $scope.instrumentQuestion.project_id = $scope.project_id
    $scope.instrumentQuestion.$update({},
      (data, headers) ->
      (result, headers) ->
        alert(result.data.errors)
    )

  $scope.getQuestion = (loopQ) ->
    _.findWhere($scope.instrumentQuestions, {identifier: loopQ.looped})

  $scope.hasLoops = (type) ->
    type in ['INTEGER', 'SELECT_MULTIPLE', 'SELECT_MULTIPLE_WRITE_OTHER',
    'LIST_OF_TEXT_BOXES', 'LIST_OF_INTEGER_BOXES']

  $scope.deleteNextQuestion = (nextQuestion) ->
    if confirm('Are you sure you want to delete this skip pattern?')
      setRouteParameters(nextQuestion)
      if nextQuestion.id
        nextQuestion.$delete({},
          (data, headers) ->
            $scope.nextQuestions.splice($scope.nextQuestions.indexOf(nextQuestion), 1)
          (result, headers) ->
            alert(result.data.errors)
        )

  $scope.deleteMultiSkip = (multiSkip) ->
    if confirm('Are you sure you want to delete this skip?')
      setRouteParameters(multiSkip)
      if multiSkip.id
        multiSkip.$delete({},
          (data, headers) ->
            $scope.multipleSkips.splice($scope.multipleSkips.indexOf(multiSkip), 1)
          (result, headers) ->
            alert(result.data.errors)
        )

  $scope.deleteFollowUpQuestion = (followUp) ->
    if confirm('Are you sure you want to delete this follow-up?')
      setRouteParameters(followUp)
      if followUp.id
        followUp.$delete({},
          (data, headers) ->
            $scope.followUpQuestions.splice($scope.followUpQuestions.indexOf(followUp), 1)
          (result, headers) ->
            alert(result.data.errors)
        )

  $scope.deleteConditionSkip = (conditionSkip) ->
    if confirm('Are you sure you want to delete this condition skip pattern?')
      setRouteParameters(conditionSkip)
      if conditionSkip.id
        conditionSkip.$delete({},
          (data, headers) ->
            $scope.conditionSkips.splice($scope.conditionSkips.indexOf(conditionSkip), 1)
          (result, headers) ->
            alert(result.data.errors)
        )

  setRouteParameters = (obj) ->
    obj.instrument_question_id = $scope.instrumentQuestion.id
    obj.project_id = $scope.project_id
    obj.instrument_id = $scope.instrument_id

]

App.controller 'FollowUpsCtrl', ['$scope', '$stateParams', 'FollowUpQuestion',
'Setting', 'InstrumentQuestion', 'Option', 'Question', ($scope, $stateParams,
FollowUpQuestion, Setting, InstrumentQuestion, Option, Question) ->
  $scope.options = []
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id

  $scope.instrumentQuestion = InstrumentQuestion.get({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'id': $scope.id
  }, ->
    if $scope.instrumentQuestion.option_set_id
      regularOptions = Option.query({'option_set_id': $scope.instrumentQuestion.option_set_id}, ->
        angular.forEach regularOptions, (option, index) ->
          $scope.options.push(option)
      )
    if $scope.instrumentQuestion.special_option_set_id
      specialOptions = Option.query({'option_set_id': $scope.instrumentQuestion.special_option_set_id}, ->
        angular.forEach specialOptions, (option, index) ->
          $scope.options.push(option)
      )
  )

  $scope.followingUpQuestions = FollowUpQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })

  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.settings = Setting.get({})

  $scope.questionsBefore = (question) ->
    $scope.instrumentQuestions.slice(0, (question.number_in_instrument - 1))

  $scope.followUpQuestions = (question) ->
    questions = []
    if $scope.settings.question_types_with_follow_ups
      angular.forEach $scope.questionsBefore(question), (q, i) ->
        if q.type in $scope.settings.question_types_with_follow_ups
          questions.push(q)
    questions

  $scope.addFollowUp = () ->
    followup = new FollowUpQuestion()
    followup.position = $scope.followingUpQuestions.length
    followup.instrument_question_id = $scope.instrumentQuestion.id
    followup.question_identifier = $scope.instrumentQuestion.identifier
    $scope.followingUpQuestions.push(followup)

  $scope.saveFollowUps = () ->
    count = 0
    index = $scope.instrumentQuestion.text.indexOf("[followup]")
    while (index > -1)
      ++count
      index = $scope.instrumentQuestion.text.indexOf("[followup]", ++index)
    if count == $scope.followingUpQuestions.length
      $scope.instrumentQuestion.project_id = $scope.project_id
      question = new Question()
      question.id = $scope.instrumentQuestion.question_id
      question.question_set_id = $scope.instrumentQuestion.question_set_id
      question.text = $scope.instrumentQuestion.text
      question.$update({},
        (data, headers) ->
        (result, headers) ->
          alert(result.data.errors)
      )
      angular.forEach $scope.followingUpQuestions, (followup, index) ->
        followup.project_id = $scope.project_id
        followup.instrument_id = $scope.instrument_id
        if followup.id
          followup.$update({},
            (data, headers) ->
            (result, headers) ->
              alert(result.data.errors)
          )
        else
          followup.$save({},
            (data, headers) ->
            (result, headers) ->
              alert(result.data.errors)
          )
    else
      alert('You need to insert the right number of "[followup]" in the question text')

  $scope.deleteFollowUp = (followup) ->
    followup.project_id = $scope.project_id
    followup.instrument_id = $scope.instrument_id
    if confirm('Are you sure you want to delete this followup?')
      if followup.id
        followup.$delete({},
          (data, headers) ->
            $scope.followingUpQuestions.splice($scope.followingUpQuestions.indexOf(followup), 1)
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        $scope.followingUpQuestions.splice($scope.followingUpQuestions.indexOf(followup), 1)

]

App.controller 'NextQuestionsCtrl', ['$scope', '$stateParams', 'InstrumentQuestion', 'Setting',
'Option', 'NextQuestion', ($scope, $stateParams, InstrumentQuestion, Setting, Option, NextQuestion) ->
  $scope.options = []
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id

  $scope.instrumentQuestion = InstrumentQuestion.get({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'id': $scope.id
  }, ->
    if $scope.instrumentQuestion.option_set_id
      regularOptions = Option.query({'option_set_id': $scope.instrumentQuestion.option_set_id}, ->
        angular.forEach regularOptions, (option, index) ->
          $scope.options.push(option)
      )
    if $scope.instrumentQuestion.special_option_set_id
      specialOptions = Option.query({'option_set_id': $scope.instrumentQuestion.special_option_set_id}, ->
        angular.forEach specialOptions, (option, index) ->
          $scope.options.push(option)
      )
  )
  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })
  $scope.settings = Setting.get({})
  $scope.nextQuestions = NextQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })

  $scope.addNextQuestion = () ->
    $scope.newNextQuestion = new NextQuestion()
    $scope.newNextQuestion.instrument_question_id = $scope.instrumentQuestion.id
    $scope.newNextQuestion.question_identifier = $scope.instrumentQuestion.identifier
    $scope.newNextQuestion.project_id = $scope.project_id
    $scope.newNextQuestion.instrument_id = $scope.instrument_id
    $scope.nextQuestions.push($scope.newNextQuestion)

  $scope.saveSkip = (nextQuestion) ->
    setRouteParameters(nextQuestion)
    exists = _.where($scope.nextQuestions, {option_identifier: nextQuestion.option_identifier})
    if exists.length > 1
      alert 'Skip for Option is already set!'
    else
      if nextQuestion.id
        nextQuestion.$update({},
          (data, headers) ->
            nextQuestion = data
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        nextQuestion.$save({},
          (data, headers) ->
            nextQuestion = data
          (result, headers) ->
            alert(result.data.errors)
        )

  $scope.deleteSkip = (nextQuestion) ->
    if confirm('Are you sure you want to delete this skip pattern?')
      setRouteParameters(nextQuestion)
      if nextQuestion.id
        nextQuestion.$delete({},
          (data, headers) ->
            $scope.nextQuestions.splice($scope.nextQuestions.indexOf(nextQuestion), 1)
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        $scope.nextQuestions.splice($scope.nextQuestions.indexOf(nextQuestion), 1)

  $scope.questionTypesWithSkipPatterns = (questionType) ->
    if $scope.settings.question_with_skips
      questionType in $scope.settings.question_with_skips

  $scope.questionsAfter = (question) ->
    questions = _.sortBy($scope.instrumentQuestions, 'number_in_instrument')
    questions.slice(question.number_in_instrument, questions.length)

  setRouteParameters = (nextQuestion) ->
    nextQuestion.instrument_question_id = $scope.instrumentQuestion.id
    nextQuestion.project_id = $scope.project_id
    nextQuestion.instrument_id = $scope.instrument_id

]

App.controller 'MultipleSkipsCtrl', ['$scope', '$stateParams', 'InstrumentQuestion',
'Setting', 'Option', 'MultipleSkip', ($scope, $stateParams, InstrumentQuestion,
Setting, Option, MultipleSkip) ->
  $scope.options = []
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id
  $scope.showSkips = true

  $scope.instrumentQuestion = InstrumentQuestion.get({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'id': $scope.id
  }, ->
    if $scope.instrumentQuestion.option_set_id
      regularOptions = Option.query({'option_set_id': $scope.instrumentQuestion.option_set_id}, ->
        angular.forEach regularOptions, (option, index) ->
          $scope.options.push(option)
      )
    if $scope.instrumentQuestion.special_option_set_id
      specialOptions = Option.query({'option_set_id': $scope.instrumentQuestion.special_option_set_id}, ->
        angular.forEach specialOptions, (option, index) ->
          $scope.options.push(option)
      )
  )

  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })
  $scope.multipleSkips = MultipleSkip.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })
  $scope.settings = Setting.get({})

  $scope.questionTypesWithSkipPatterns = (questionType) ->
    if $scope.settings.question_with_skips
      questionType in $scope.settings.question_with_skips

  $scope.questionsAfter = (question) ->
    questions = _.sortBy($scope.instrumentQuestions, 'number_in_instrument')
    questions.slice(question.number_in_instrument, questions.length)

  $scope.deleteMultiSkip = (multiSkip) ->
    if confirm('Are you sure you want to delete this skip?')
      setRouteParameters(multiSkip)
      if multiSkip.id
        multiSkip.$delete({},
          (data, headers) ->
            $scope.multipleSkips.splice($scope.multipleSkips.indexOf(multiSkip), 1)
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        $scope.multipleSkips.splice($scope.multipleSkips.indexOf(multiSkip), 1)

  $scope.addMultiSkip = () ->
    $scope.showSkips = false
    $scope.skipQuestion = new MultipleSkip()
    $scope.skipQuestion.question_identifier = $scope.instrumentQuestion.identifier
    $scope.skipQuestion.questionsToSkip = []

  $scope.saveMultiSkip = () ->
    angular.forEach $scope.skipQuestion.questionsToSkip, (question, index) ->
      multiSkip = new MultipleSkip()
      multiSkip.question_identifier = $scope.instrumentQuestion.identifier
      multiSkip.option_identifier = $scope.skipQuestion.option_identifier
      multiSkip.value = $scope.skipQuestion.value
      multiSkip.skip_question_identifier = question.identifier
      saveSkip(multiSkip)
    $scope.showSkips =true

  saveSkip = (multiSkip) ->
    exists = _.where($scope.multipleSkips, {
      option_identifier: multiSkip.option_identifier,
      skip_question_identifier: multiSkip.skip_question_identifier,
      instrument_question_id: multiSkip.instrument_question_id
    })
    if exists.length > 1
      alert 'Skip question for option is already set!'
    else
      setRouteParameters(multiSkip)
      multiSkip.$save({},
        (data, headers) ->
          $scope.multipleSkips.push(data)
        (result, headers) ->
          alert(result.data.errors)
      )

  $scope.delete = () ->
    $scope.showSkips = true
    $scope.skipQuestion = undefined

  setRouteParameters = (nextQuestion) ->
    nextQuestion.instrument_question_id = $scope.instrumentQuestion.id
    nextQuestion.project_id = $scope.project_id
    nextQuestion.instrument_id = $scope.instrument_id

]

App.controller 'ConditionSkipsCtrl', ['$scope', '$stateParams', 'InstrumentQuestion',
'Setting', 'Option', 'ConditionSkip', ($scope, $stateParams, InstrumentQuestion,
Setting, Option, ConditionSkip) ->
  $scope.options = []
  $scope.conditionQuestionOptions = []
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id

  $scope.settings = Setting.get({}, ->
    $scope.skipConditions = $scope.settings.skip_conditions
  )
  $scope.instrumentQuestion = InstrumentQuestion.get({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'id': $scope.id
  }, ->
    questionOptions($scope.instrumentQuestion, $scope.options)
  )

  questionOptions = (instrumentQuestion, optionsArray) ->
    if instrumentQuestion.option_set_id
      regularOptions = Option.query({'option_set_id': instrumentQuestion.option_set_id}, ->
        angular.forEach regularOptions, (option, index) ->
          if (optionsArray.indexOf(option) == -1)
            optionsArray.push(option)
      )
    if instrumentQuestion.special_option_set_id
      specialOptions = Option.query({'option_set_id': instrumentQuestion.special_option_set_id}, ->
        angular.forEach specialOptions, (option, index) ->
          if (optionsArray.indexOf(option) == -1)
            optionsArray.push(option)
      )

  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.conditionSkips = ConditionSkip.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })

  $scope.conditionQuestions = (question) ->
    questions = []
    if $scope.settings.question_types_with_follow_ups
      angular.forEach $scope.questionsBefore(question), (q, i) ->
        if q.type in $scope.settings.question_types_with_follow_ups
          questions.push(q)
    questions

  $scope.questionsAfter = (question) ->
    questions = _.sortBy($scope.instrumentQuestions, 'number_in_instrument')
    questions.slice(question.number_in_instrument, questions.length)

  $scope.questionsBefore = (question) ->
    $scope.instrumentQuestions.slice(0, (question.number_in_instrument - 1))

  $scope.conditionOptions = (question, conditionSkip) ->
    conditionQuestion = _.findWhere($scope.conditionQuestions(question), {
      identifier: conditionSkip.condition_question_identifier
    })
    if conditionQuestion
      questionOptions(conditionQuestion, $scope.conditionQuestionOptions)

  $scope.addConditionSkip = () ->
    conditionSkip = new ConditionSkip()
    conditionSkip.instrument_question_id = $scope.instrumentQuestion.id
    conditionSkip.question_identifier = $scope.instrumentQuestion.identifier
    conditionSkip.project_id = $scope.project_id
    conditionSkip.instrument_id = $scope.instrument_id
    $scope.conditionSkips.push(conditionSkip)

  $scope.saveConditionSkip = (skip) ->
    setRouteParameters(skip)
    exists = _.where($scope.conditionSkips, {
      condition_question_identifier: skip.condition_question_identifier,
      condition_option_identifier: skip.condition_option_identifier,
      option_identifier: skip.option_identifier,
      condition: skip.condition
    })
    if exists.length > 1
      alert 'Skip for Option is already set!'
    else
      if skip.id
        skip.$update({},
          (data, headers) ->
            skip = data
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        skip.$save({},
          (data, headers) ->
            skip = data
          (result, headers) ->
            alert(result.data.errors)
        )

  $scope.deleteConditionSkip = (skip) ->
    if confirm('Are you sure you want to delete this skip pattern?')
      setRouteParameters(skip)
      if skip.id
        skip.$delete({},
          (data, headers) ->
            $scope.conditionSkips.splice($scope.conditionSkips.indexOf(skip), 1)
          (result, headers) ->
            alert(result.data.errors)
        )
      else
        $scope.conditionSkips.splice($scope.conditionSkips.indexOf(skip), 1)

  setRouteParameters = (skip) ->
    skip.instrument_question_id = $scope.instrumentQuestion.id
    skip.project_id = $scope.project_id
    skip.instrument_id = $scope.instrument_id

]

App.controller 'LoopsCtrl', ['$scope', '$stateParams', 'InstrumentQuestion',
'LoopQuestion', 'Option', ($scope, $stateParams, InstrumentQuestion, LoopQuestion, Option) ->
  $scope.project_id = $stateParams.project_id
  $scope.instrument_id = $stateParams.instrument_id
  $scope.id = $stateParams.id

  $scope.hasLoops = (type) ->
    type in ['INTEGER', 'SELECT_MULTIPLE', 'SELECT_MULTIPLE_WRITE_OTHER',
    'LIST_OF_TEXT_BOXES', 'LIST_OF_INTEGER_BOXES']

  $scope.instrumentQuestion = InstrumentQuestion.get({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'id': $scope.id
  }, ->
    if $scope.instrumentQuestion.option_set_id
      $scope.options = Option.query({'option_set_id': $scope.instrumentQuestion.option_set_id})
  )

  $scope.loopQuestions = LoopQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id,
    'instrument_question_id': $scope.id
  })

  $scope.instrumentQuestions = InstrumentQuestion.query({
    'project_id': $scope.project_id,
    'instrument_id': $scope.instrument_id
  })

  $scope.isIntegerQuestion = (type) ->
    type == 'INTEGER'

  $scope.questionsAfter = () ->
    questions = _.sortBy($scope.instrumentQuestions, 'number_in_instrument')
    questions.slice($scope.instrumentQuestion.number_in_instrument, questions.length)

  $scope.getQuestion = (loopQ) ->
    _.findWhere($scope.instrumentQuestions, {identifier: loopQ.looped})

  $scope.delete = (loopQuestion) ->
    if confirm('Are you sure you want to delete this looped question?')
      loopQuestion.project_id = $scope.project_id
      loopQuestion.instrument_id = $scope.instrument_id
      loopQuestion.$delete({},
        (data, headers) ->
          $scope.loopQuestions.splice($scope.loopQuestions.indexOf(loopQuestion), 1)
        (result, headers) ->
          alert(result.data.errors)
      )

  $scope.createLoop = () ->
    $scope.newLoop = true
    $scope.loopQuestion = new LoopQuestion()
    $scope.loopQuestion.project_id = $scope.project_id
    $scope.loopQuestion.instrument_id = $scope.instrument_id
    $scope.loopQuestion.instrument_question_id = $scope.id
    $scope.loopQuestion.parent = $scope.instrumentQuestion.identifier

  $scope.saveLoop = () ->
    angular.forEach $scope.loopQuestion.looped, (questionToLoop, index) ->
      loopQ = angular.copy($scope.loopQuestion)
      loopQ.looped = questionToLoop.identifier
      saveLoopQuestion(loopQ)

  saveLoopQuestion = (loopQ) ->
    if (loopQ.indices)
      indices = ""
      angular.forEach loopQ.indices, (option, index) ->
        ind = $scope.options.indexOf(option)
        if ind != -1
          indices = indices + ind + ","
      indices = indices.substring(0, indices.length - 1)
      loopQ.option_indices = indices
      loopQ.indices = null
    loopQ.$save({},
      (data, headers) ->
        $scope.loopQuestions.push(data)
        $scope.newLoop = false
      (result, headers) ->
        alert(result.data.errors)
    )

  $scope.update = (loopQ) ->
    loopQ.project_id = $scope.project_id
    loopQ.instrument_id = $scope.instrument_id
    loopQ.$update({},
      (data, headers) ->
      (result, headers) ->
        alert(result.data.errors)
    )

]
