# score_type: multiple_select
# question_type: SELECT_MULTIPLE, SELECT_MULTIPLE_WRITE_OTHER
class Bank < Scheme
  def score(survey, unit)
    scores = []
    unit.questions.each do |question|
      response = survey.response_for_question(question)
      next unless response
      scores << get_scores_hash(unit).key(option_ids(question, response).sort)
    end
    scores.max
  end

  def get_scores_hash(unit)
    scores_hash = {}
    unit.option_scores.all.group_by(&:value).each do |score, options|
      scores_hash[score] = options.map(&:option_id).sort
    end
    scores_hash
  end
end
