App.controller 'CopyQuestionsCtrl', ['$scope', 'Instrument', 'Question', ($scope, Instrument, Question) ->
  $scope.init = (project_id, instrument_id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    $scope.instruments = Instrument.query({"project_id": project_id})
    $scope.questions = Question.query({"project_id": project_id, "instrument_id": instrument_id})

  $scope.copyQuestions = () ->
    counter = 1
    for q in $scope.questions
      if q.checked == true
        $scope.copyHelper(q, counter)
        counter += 1
    $scope.searchBarVisibility = true
    $scope.questionVisibility = true
    (instrument.checked = false) for instrument in $scope.instruments
    (question.checked = false) for question in $scope.questions

  $scope.copyHelper = (question, counter) ->
    for instrument in $scope.instruments
      if instrument.checked == true
        new_position = instrument.question_count + counter
        copy_question = new CopyQuestion()
        copy_question.project_id = $scope.project_id
        copy_question.instrument_id = $scope.instrument_id
        copy_question.id = question.id
        copy_question.destination_instrument_id = instrument.id
        copy_question.copy_question_identifier = question.question_identifier + "_" + $scope.generateUniqueId()
        copy_question.number_in_instrument = new_position
        copy_question.$copy()

  $scope.generateUniqueId = (length=8) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length
]