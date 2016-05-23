class Score
  attr :qid, :survey_id, :survey_uuid, :device_label, :device_user, :center_id, :instrument_id, :question_type,
       :raw_score, :response, :scheme_description, :weight, :domain, :sub_domain

  def initialize(qid, s_id, s_uuid, d_label, d_user, c_id, i_id, q_type, res)
    @qid = qid
    @survey_id = s_id
    @survey_uuid = s_uuid
    @device_label = d_label
    @device_user = d_user
    @center_id = c_id.to_i
    @instrument_id = i_id
    @question_type = q_type
    @response = res
  end

  def raw_score=(score)
    @raw_score = score
  end

  def weight=(weight)
    @weight = weight
  end

  def scheme_description=(name)
    @scheme_description = name
  end

  def domain=(dm)
    @domain = dm
  end

  def sub_domain=(sdm)
    @sub_domain = sdm
  end

  def weighted_score
    unless raw_score.nil?
      return nil if raw_score.class == String && raw_score.to_f == 0
      score = raw_score
      factor = weight
      if raw_score.class == String
        score = raw_score.strip.to_f
      end
      if weight.class == String
        factor = weight.strip.to_f
      end
      (factor * score).round(2)
    end
  end

end