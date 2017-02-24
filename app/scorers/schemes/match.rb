# score_type: single_select
# question_type: SELECT_ONE, SELECT_ONE_WRITE_OTHER
class Match < Scheme
  # Picks the maximum score possible based on the responses to the questions
  # within the unit.
  # Caveat: If a skip pattern causes a jump to a question within the unit
  # and the question jumped to is not given a response, the unit will
  # not be scored
  def score(survey, unit)
    scores = []
    unit.questions.each do |question|
      response = survey.response_for_question(question)
      next unless response
      id = option_ids(question, response).try(:first)
      scores.concat(unit.option_scores.where(option_id: id)) if id
    end
    scores.reject { |s| s.value.nil? }.max_by(&:value).try(:value)
  end
end
