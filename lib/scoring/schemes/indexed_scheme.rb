class IndexedScheme < ScoringScheme

  def ref_option_index_raw_score=(str)
    if str.include?('...')
      index_score_hash = {}
      str.strip.split.each do |index_score|
        index_score_arr = index_score.split(';')
        ranges = index_score_arr[0].split('...')
        index_score_hash[ranges[0].to_i...ranges[1].to_i] = index_score_arr[1]
      end
      @ref_option_index_raw_score = index_score_hash
    else
      super
    end
  end

  def score(obj, ref_score)
    return nil if obj.response.blank? || ref_option_index_raw_score.blank?
    #TODO quick and dirty
    if question_type == 'SELECT_MULTIPLE_WRITE_OTHER' && !relevant_index.nil?
      if obj.response.include?(relevant_index.to_s)
        return 7
      else
        return 1
      end
    end
    #TODO quick and dirty
    if question_type == 'SELECT_ONE' && !relevant_index.nil?
      if ref_score.response.include?(relevant_index.to_s)
        return ref_option_index_raw_score[obj.response]
      else
        return 1
      end
    end

    if reference_qid
      return nil if ref_score.nil? || ref_score.response.blank? #TODO Why is ref_score nil
      reference_hash = ref_option_index_raw_score[ref_score.response]
      if reference_hash.nil?
        #TODO Imputed/Inferred
        return 1
      end
      return reference_hash['_'] if reference_hash && reference_hash.keys.include?('_')
      return nil if reference_hash && reference_hash[obj.response] == '-'
      reference_hash[obj.response]
    else
      if question_type == 'INTEGER'
        selected = ref_option_index_raw_score.select { |range| range === obj.response.to_i }
        return selected.values.first
      end
      if ref_option_index_raw_score[obj.response].class == Hash
        center_code = CalculationScheme.centers.find { |ctr| ctr.id == obj.center_id }.code
        return ref_option_index_raw_score[center_code.to_s][obj.response]
      end
      ref_option_index_raw_score[obj.response]
    end
  end

end