# score_type: simple_search
# question_type: FREE_RESPONSE, LIST_OF_TEXT_BOXES
class Search < Scheme
  def score(survey, unit)
    scores = []
    unit.questions.each do |question|
      response = survey.response_for_question(question)
      next unless response
      get_scores_hash(unit).each do |key, values|
        key.include?(response.text) ? scores.concat(exists_a(values, true)) : scores.concat(exists_a(values, false))
      end
    end
    scores.max_by(&:value).try(:value)
  end

  private

  def exists_a(col, status)
    col.where(exists: status).to_a
  end

  def get_scores_hash(unit)
    hash = {}
    unit.option_scores.order(:label).each do |score|
      hash[score.label] = unit.option_scores.where(label: score.label)
    end
    hash
  end
end
