class SumScheme < ScoringScheme
  def score(obj)
    return nil if obj.response.blank? || key_score_mapping.blank?
    responses = obj.response.split(',')
    responses.delete(exclude_index) if exclude_index
    key_score_mapping[responses.size.to_s]
  end
end