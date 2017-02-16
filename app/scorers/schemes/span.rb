# score_type: range
# question_type: INTEGER, DECIMAL_NUMBER, SLIDER, LABELED_SLIDER, RATING
class Span < Scheme
  def score(survey, unit)
    scores = []
    unit.questions.each do |question|
      response = survey.response_for_question(question)
      next unless response
      scores << get_scores_hash(unit).select { |range| range === response.text.to_f }.values.first if response.text
    end
    scores.max
  end

  def get_scores_hash(unit)
    hash = {}
    unit.option_scores.each do |opts|
      range = opts.label.split('..').map(&:to_f) if opts.label.include? '..'
      hash[range[0]..range[1]] = opts.value if range
    end
    hash
  end
end
