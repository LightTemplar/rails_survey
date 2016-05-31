class RosterScheme < ScoringScheme
  attr :question_text

  MIN_AGE = 84.0
  MAX_AGE = 216.0

  def question_text=(text)
    @question_text = text
  end

  def get_age_school_score(children_sheet, center_id)
    age_and_school_scores = []
    children_sheet.drop(3).each do |row|
      if !row[1].blank? && is_correct_id(row[1]) && !row[2].blank? && !row[17].blank?
        if row[2].class == Float && row[2] >= MIN_AGE  && row[2] <= MAX_AGE
          if row[17].strip.downcase == 'si'
            age_and_school_scores << 7
          elsif row[17].strip.downcase == 'no'
            age_and_school_scores << 1
          end
        end
      end
    end
    get_roster_score(age_and_school_scores, center_id)
  end

  def get_vaccination_score(children_sheet, center_id)
    vaccination_scores = []
    center_code = Center.get_centers.find{|ctr| ctr.id == center_id}.code
    children_sheet.drop(3).each do |row|
      if !row[1].blank? && is_correct_id(row[1]) && !row[2].blank? && !row[18].blank?
        if row[18].strip.downcase == 'si'
          vaccination_scores << 7
        else
          vaccination_scores << center_code == 1 ? 1 : 4
        end
      end
    end
    get_roster_score(vaccination_scores, center_id)
  end

end