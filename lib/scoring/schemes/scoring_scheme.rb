class ScoringScheme
  attr :qid, :reference_qid, :question_type, :description, :weight, :key_score_mapping,
       :ref_option_index_raw_score, :word_bank, :exclude_index, :relevant_index

  def initialize(q_id, q_type, desc, weight)
    @qid = q_id
    @question_type = q_type
    @description = desc
    @weight = weight
  end

  def relevant_index=(num)
    @relevant_index = num.to_i
  end

  def key_score_mapping=(str)
    @key_score_mapping = str_arr_to_hash(str.strip.split)
  end

  def str_arr_to_hash(options_scores_arr)
    index_score_hash = {}
    options_scores_arr.each do |index_score|
      index_score_arr = index_score.split(';')
      index_score_hash[index_score_arr[0]] = index_score_arr[1]
    end
    index_score_hash
  end

  def qid=(qid)
    @qid = qid
  end

  def reference_qid=(qid)
    @reference_qid = qid
  end

  def ref_option_index_raw_score=(str)
    ref_hash = {}
    if str.include?(',')
      str.strip.split.each do |ref_index|
        ref_index_arr = ref_index.split(',')
        value = {}
        value_arr = ref_index_arr[1].split(';')
        value[value_arr[0]] = value_arr[1]
        if ref_hash[ref_index_arr[0]]
          ref_hash[ref_index_arr[0]] = ref_hash[ref_index_arr[0]].merge!(value)
        else
          ref_hash[ref_index_arr[0]] = value
        end
      end
      @ref_option_index_raw_score = ref_hash
    else
      @ref_option_index_raw_score = str_arr_to_hash(str.strip.split)
    end
  end

  def word_bank=(words)
    @word_bank = words
  end

  def exclude_index=(index)
    @exclude_index = index
  end

  # Catchall scorer
  def score(response)
    response.blank? ? nil : 0
  end

  def assign_weight(center_id = nil)
    assigned_weight = weight
    if center_id && center_id != 0
      center_code = CalculationScheme.centers.find{|ctr| ctr.id == center_id}.code
      if weight.class == String && weight.include?(':')
        residential_weights = weight.split
        weight_one = residential_weights[0].split(':')
        weight_two = residential_weights[1].split(':')
        if weight_one[0] == center_code.to_s
          assigned_weight = weight_one[1]
        else
          assigned_weight = weight_two[1]
        end
      end
    end
    assigned_weight
  end

  def is_number(string)
    Integer(string || '')
  rescue ArgumentError
    nil
  end

end