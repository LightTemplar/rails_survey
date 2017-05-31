class ChildRosterScheme < ScoringScheme
  attr_reader :question_text

  MIN_AGE = 84.0
  MAX_AGE = 216.0
  DAYS_PER_YEAR = 365
  DAYS_PER_MONTH = 30
  DAYS_PER_WEEK = 7

  attr_writer :question_text

  def key_score_mapping=(str)
    time_score_hash = {}
    scores_array = str.split(/\r?\n/)
    scores_array.each do |score_str|
      single_score = score_str.split(';')
      if single_score[0].include?('...')
        time_range = single_score[0].split('...')
        time_score_hash[time_range[0].to_f...time_range[1].to_f] = single_score[1]
      elsif single_score[0].include?('..')
        time_range = single_score[0].split('..')
        time_score_hash[time_range[0].to_f..time_range[1].to_f] = single_score[1]
      end
    end
    @key_score_mapping = time_score_hash
  end

  def get_age_school_score(children_sheet, center_id)
    age_and_school_scores = []
    children_sheet.drop(3).each do |row|
      next unless is_correct_id(row[1]) && !row[2].blank? && !row[17].blank?
      if row[2].class == Float && row[2] >= MIN_AGE && row[2] <= MAX_AGE
        if row[17].strip.casecmp('si').zero?
          age_and_school_scores << 7
        elsif row[17].strip.casecmp('no').zero?
          age_and_school_scores << 1
        end
      end
    end
    get_roster_score(age_and_school_scores, center_id)
  end

  def get_vaccination_score(children_sheet, center_id)
    vaccination_scores = []
    center = Center.get_centers.find { |ctr| ctr.id == center_id }
    center_code = center ? center.code : 1
    children_sheet.drop(3).each do |row|
      if is_correct_id(row[1]) && !row[2].blank? && !row[18].blank?
        if row[18].strip.casecmp('si').zero?
          vaccination_scores << 7
        else
          vaccination_scores << center_code == 1 ? 1 : 4
        end
      end
    end
    get_roster_score(vaccination_scores, center_id)
  end

  def get_lag_time_score(children_sheet, center_id)
    lag_time_scores = []
    roster_date = children_sheet.row(1)[12]
    roster_date = children_sheet.row(1)[11] if roster_date.blank?
    roster_date = children_sheet.row(1)[9] if roster_date.class != Date
    children_sheet.drop(3).each do |row|
      next unless is_correct_id(row[1]) && !row[12].blank?
      arrival_date = row[4]
      days_in_center = nil
      if row[12].class == String
        numbers = row[12].scan(/\d+/)
        if row[12].include?('año') && row[12].include?('mes')
          days_in_center = (numbers[0].to_i * DAYS_PER_YEAR) + (numbers[1].to_i * DAYS_PER_MONTH)
        elsif row[12].include?('mes') && row[12].include?('sem')
          days_in_center = (numbers[0].to_i * DAYS_PER_MONTH) + (numbers[1].to_i * DAYS_PER_WEEK)
        elsif row[12].include?('mes') && row[12].include?('dia')
          days_in_center = (numbers[0].to_i * DAYS_PER_MONTH) + numbers[1].to_i
        elsif row[12].include?('mes')
          if numbers[1] && numbers[2]
            days_in_center = numbers[0].to_i * DAYS_PER_MONTH + ((numbers[1].to_f / numbers[2].to_f) * DAYS_PER_MONTH)
          else
            days_in_center = numbers[0].to_i * DAYS_PER_MONTH
          end
        elsif row[12].include?('año')
          days_in_center = row[12].scan(/\d+/)[0].to_i * DAYS_PER_YEAR
        elsif row[12].include?('mes')
          days_in_center = row[12].scan(/\d+/)[0].to_i * DAYS_PER_MONTH
        elsif row[12].downcase.include?('sem')
          days_in_center = row[12].scan(/\d+/)[0].to_i * DAYS_PER_WEEK
        elsif row[12].include?('dia') || row[12].include?('día')
          days_in_center = row[12].scan(/\d+/)[0].to_i
        end

    end
      get_roster_score(lag_time_scores, center_id)
    end
end
end
