# score_type: single_select
# question_type: SELECT_ONE, SELECT_ONE_WRITE_OTHER
class Match < Scheme
  def score(survey, unit)
    scores = []
    unit.questions.each do |question|
      response = survey.response_for_question(question)
      next unless response
      id = option_ids(question, response).try(:first)
      scores.concat(unit.option_scores.where(option_id: id)) if id
    end
    scores.max_by(&:value).try(:value)
  end
end
