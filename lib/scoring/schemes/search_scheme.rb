class SearchScheme < ScoringScheme
  def score(obj)
    return nil if obj.response.blank? || key_score_mapping.blank?
    (obj.response.downcase.split(',') & word_bank.downcase.split(',')).empty? ? key_score_mapping['excludes'] :
        key_score_mapping['includes']
  end
end