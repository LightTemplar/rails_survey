App.controller 'ShowInstrumentQuestionCtrl', ['$scope', '$stateParams', 'InstrumentQuestion', 'Setting', 'Option',
  'NextQuestion', 'MultipleSkip', 'FollowUpQuestion', 'Question', ($scope, $stateParams, InstrumentQuestion, Setting,
    Option, NextQuestion, MultipleSkip, FollowUpQuestion, Question) ->
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

    $scope.multipleSkips = MultipleSkip.query({
      'project_id': $scope.project_id,
      'instrument_id': $scope.instrument_id,
      'instrument_question_id': $scope.id
    })

    $scope.followingUpQuestions = FollowUpQuestion.query({
      'project_id': $scope.project_id,
      'instrument_id': $scope.instrument_id,
      'instrument_question_id': $scope.id
    })

    $scope.questionTypesWithSkipPatterns = (questionType) ->
      if $scope.settings.question_with_skips
        questionType in $scope.settings.question_with_skips

    $scope.questionsAfter = (question) ->
      questions = _.sortBy($scope.instrumentQuestions, 'number_in_instrument')
      questions.slice(question.number_in_instrument, questions.length)

    $scope.questionsBefore = (question) ->
      $scope.instrumentQuestions.slice(0, (question.number_in_instrument - 1))

    $scope.questionTypesWithMultipleSkips = (questionType) ->
      if $scope.settings.question_with_multiple_skips
        questionType in $scope.settings.question_with_multiple_skips

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

    $scope.deleteMultiSkip = (multiSkip) ->
      if confirm('Are you sure you want to delete this skip?')
        setRouteParameters(multiSkip)
        if multiSkip.id
          multiSkip.$delete({},
            (data, headers) ->
              $scope.multipleSkips.splice($scope.multipleSkips.indexOf(multiSkip, 1))
            (result, headers) ->
              alert(result.data.errors)
          )
        else
          $scope.multipleSkips.splice($scope.multipleSkips.indexOf(multiSkip, 1))

    $scope.addMultiSkip = () ->
      skipQuestion = new MultipleSkip()
      skipQuestion.question_identifier = $scope.instrumentQuestion.identifier
      setRouteParameters(skipQuestion)
      $scope.multipleSkips.push(skipQuestion)

    $scope.saveMultiSkip = (multiSkip) ->
      exists = _.where($scope.multipleSkips, {
        option_identifier: multiSkip.option_identifier,
        skip_question_identifier: multiSkip.skip_question_identifier,
        instrument_question_id: multiSkip.instrument_question_id
      })
      if exists.length > 1
        alert 'Skip question for option is already set!'
      else
        setRouteParameters(multiSkip)
        if multiSkip.id
          multiSkip.$update({},
            (data, headers) ->
              multiSkip = data
            (result, headers) ->
              alert(result.data.errors)
          )
        else
          multiSkip.$save({},
            (data, headers) ->
              multiSkip = data
            (result, headers) ->
              alert(result.data.errors)
          )

    setRouteParameters = (nextQuestion) ->
      nextQuestion.instrument_question_id = $scope.instrumentQuestion.id
      nextQuestion.project_id = $scope.project_id
      nextQuestion.instrument_id = $scope.instrument_id

]
