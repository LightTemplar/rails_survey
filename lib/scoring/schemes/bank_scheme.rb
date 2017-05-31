class BankScheme < ScoringScheme
  def score(obj)
    return nil if obj.response.blank? || ref_option_index_raw_score.blank?
    raw_score = nil
    if ref_option_index_raw_score.values.first.class == String
      scores = individual_scores(obj, ref_option_index_raw_score)
      return 1 if scores.include?('1')
      return 2 if scores.include?('2')
      return 3 if scores.include?('3')
      raw_score = (scores.map(&:to_f).reduce(:+) / scores.size).round(2) unless scores.empty?
    else
      center = Center.get_centers.find { |ctr| ctr.id == obj.center_id }
      center_code = center ? center.code : 1
      scores = individual_scores(obj, ref_option_index_raw_score[center_code.to_s])
      raw_score = (scores.map(&:to_f).reduce(:+) / scores.size).round(2) unless scores.empty?
    end
    raw_score
  end

  def individual_scores(obj, mapping)
    scores = []
    responses = obj.response.split(',')
    responses.delete(exclude_index) if exclude_index # Remove Other response option if included
    responses.each do |res|
      scores.push(mapping[res])
    end
    scores.compact
  end
end
