class SearchScheme < ScoringScheme
  def score(obj)
    response = (obj.class == String || obj.nil?) ? obj : obj.response
    return nil if response.blank? || key_score_mapping.blank?
    (response.downcase.split(',') & word_bank.downcase.split(',')).empty? ? key_score_mapping['excludes'] :
        key_score_mapping['includes']
  end

  def generate_previous_care_score(children_sheet, center_id)
    previous_care_scores = []
    children_sheet.drop(3).each do |row|
      if !row[1].blank? && is_correct_id(row[1]) && !row[10].blank?
        row[10].class == Float ? previous_care = row[10].round.to_s : previous_care = row[10]
        previous_care_scores << score(previous_care)
      end
    end
    roster_score = RosterScore.new(qid, question_type, center_id, description)
    roster_score.raw_score = (previous_care_scores.map(&:to_f).reduce(:+) / previous_care_scores.size).round(2)
    roster_score.weight = assign_weight(center_id)
    roster_score.domain = domain
    roster_score.sub_domain = sub_domain
    roster_score
  end

end