class StaffRosterScheme < ScoringScheme
  attr :question_text

  def question_text=(text)
    @question_text = text
  end

  def ref_option_index_raw_score=(str)
    mapping_hash = {}
    if str.include?(',')
      str.strip.split("\n").each do |ref_index|
        code_hours_score = ref_index.split(',')
        hours_score_array = code_hours_score[1].split(';')
        hours_score_hash = generate_range_hash(hours_score_array, {})
        if mapping_hash[code_hours_score[0]]
          mapping_hash[code_hours_score[0]] = mapping_hash[code_hours_score[0]].merge!(hours_score_hash)
        else
          mapping_hash[code_hours_score[0]] = hours_score_hash
        end
      end
    else
      str.strip.split.each do |index_score|
        mapping_hash = generate_range_hash(index_score.split(';'), mapping_hash)
      end
    end
    @ref_option_index_raw_score = mapping_hash
  end

  def generate_range_hash(index_score_arr, mapping_hash)
    if index_score_arr[0].include?('..')
      ranges = index_score_arr[0].split('..')
      mapping_hash[ranges[0].to_i..ranges[1].to_i] = index_score_arr[1]
    elsif index_score_arr[0] != '0' && index_score_arr[0].to_i == 0
      mapping_hash[index_score_arr[0]] = index_score_arr[1]
    else
      mapping_hash[index_score_arr[0].to_i..index_score_arr[0].to_i] = index_score_arr[1]
    end
    mapping_hash
  end

  def calculate_staff_score(staff_sheet, center_id, first_column, second_column = nil)
    scores_array = []
    staff_sheet.drop(3).each do |row|
      if !row[1].blank? && is_correct_id(row[1])
        if !row[first_column].blank? && second_column && !row[second_column].blank?
          total = nil
          if row[first_column].class == Float && row[second_column].class == Float
            total = row[first_column] + row[second_column]
          else
            current = row[first_column] == '-' ? 0 : row[first_column]
            past = row[second_column] == '-' ? 0 : row[second_column]
            total = current + past if current.is_a?(Numeric) && past.is_a?(Numeric)
          end
          if total
            scores_array << ref_option_index_raw_score.select { |value| value === total }.values.first
          else
            scores_array << nil
          end
        elsif !row[first_column].blank?
          if row[first_column].class == Float
            scores_array << ref_option_index_raw_score.select { |value| value === row[first_column].to_i }.values.first
          else
            scores_array << nil #TODO Fix #323, #turnos/semana, extra columns
          end
        end
      end
    end
    get_roster_score(scores_array, center_id)
  end

  def get_weekly_hours_score(staff_sheet, center_id, column_index)
    scores_array = []
    staff_sheet.drop(3).each do |row|
      if !row[1].blank? && is_correct_id(row[1]) && !row[column_index].blank?
        if row[column_index].class == Float
          time = row[column_index]
        elsif row[column_index].include?('m')
          hours_minutes = row[column_index].split('h')
          hours = hours_minutes[0].to_i
          minutes = hours_minutes[1].scan(/\d/).join('')
          time = hours + (minutes.to_i/60.0)
        else
          time = row[column_index].to_i
        end
        center_code = Center.get_centers.find{|ctr| ctr.id == center_id}.code
        scores_array << ref_option_index_raw_score[center_code.to_s].select{|value| value === time.round.to_i }.values.first
      end
    end
    get_roster_score(scores_array, center_id)
  end

end