class MatchingScheme < ScoringScheme
  def score(obj, ref_score)
    staff_languages = obj.response.split(',') unless obj.response.blank?
    child_languages = ref_score.response.split(',') unless ref_score.response.blank?
    common_languages = staff_languages & child_languages
    # TODO case when Other is selected
    if obj.response.blank? || ref_score.response.blank?
      4
    elsif common_languages.size > 0
      7
    else
      1
    end
  end
end