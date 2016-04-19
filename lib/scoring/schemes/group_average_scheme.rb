require 'scoring/schemes/calculation_scheme'

class GroupAverageScheme < CalculationScheme
  attr :index, :name, :qids

  def initialize(name, index, q_type, desc, weight)
    @name = name
    @index = index
    @question_type = q_type
    @description = desc
    @weight = weight
  end

  def qids=(ids)
    @qids = ids
  end

  def key_score_mapping=(str)
    if name == 'caregivers_per_shift'
      index_score_hash = {}
      str.strip.split.each do |index_score|
        index_score_arr = index_score.split(';')
        ranges = index_score_arr[0].split('...')
        index_score_hash[ranges[0].to_f.next_float...ranges[1].to_f] = index_score_arr[1]
      end
      @key_score_mapping = index_score_hash
    elsif name == 'consecutive_days_off'
      index_score_hash = {}
      str.strip.split.each do |index_score|
        index_score_arr = index_score.split(';')
        ranges = index_score_arr[0].split('...')
        index_score_hash[ranges[0].to_f...ranges[1].to_f] = index_score_arr[1]
      end
      @key_score_mapping = index_score_hash
    elsif name == 'caregivers_per_week'
      ref_hash = {}
      if str.include?(',')
        str.strip.split.each do |ref_index|
          code_resp_score_str = ref_index.split(',')
          center_code = code_resp_score_str[0].to_i
          value = {}
          resp_score_arr = code_resp_score_str[1].split(';')
          ranges = resp_score_arr[0].split('...')
          value[ranges[0].to_f...ranges[1].to_f] = resp_score_arr[1].to_i
          if ref_hash[center_code]
            ref_hash[center_code] = ref_hash[center_code].merge!(value)
          else
            ref_hash[center_code] = value
          end
        end
        @key_score_mapping = ref_hash
      end
    end
  end

  def score(center_responses, centers)
    return nil if center_responses.blank? || key_score_mapping.blank?
    scores = []
    center_responses.each do |res|
      list_responses = res.response.split(',')
      indexes = index.split(',')
      if indexes.size == 1
        response = list_responses[indexes[0].to_i]
        if is_number(response)
          if key_score_mapping.values.first.class == Hash
            center_code = centers.find{|ctr| ctr.id == res.center_id}.code
            resp_score_hash = key_score_mapping[center_code].select{|range| range === response.to_f}
            scores << resp_score_hash.values.first unless resp_score_hash.blank?
          else
            resp = key_score_mapping.select{|k| k === response.to_f}
            scores << resp.values.first unless resp.blank?
          end
        else
          #TODO what to do with non-numbers
        end
      else
        if is_number(list_responses[indexes[0].to_i]) && is_number(list_responses[indexes[1].to_i])
          resp = (list_responses[indexes[0].to_i].to_f / list_responses[indexes[1].to_i].to_f).round(2)
          response_score_mapping = key_score_mapping.select{|k| k === resp}
          scores << response_score_mapping.values.first unless response_score_mapping.blank?
        else
          #TODO deal with non-numbers
        end
      end
    end
    (scores.map(&:to_f).reduce(:+) / scores.size).round(2) unless scores.blank?
  end

end