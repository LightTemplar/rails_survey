# score_type: multiple_select_sum
# question_type: SELECT_MULTIPLE, SELECT_MULTIPLE_WRITE_OTHER
class Sum < Scheme
  def score(survey, unit)
    scores = []
    unit.questions.each do |question|
      response = survey.response_for_question(question)
      next unless response
      ids = option_ids(question, response)
      scores.concat(unit.option_scores.where(option_id: ids))
    end
    scores.sum(&:value)
  end
end
