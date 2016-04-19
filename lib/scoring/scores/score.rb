class Score
  attr :qid, :survey_id, :survey_uuid, :device_label, :device_user, :center_id, :instrument_id, :question_type,
       :raw_score, :response, :scheme_description

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

  def scheme_description=(name)
    @scheme_description = name
  end

end