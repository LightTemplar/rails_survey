class RosterScore < Score
  def initialize(qid, q_type, cid, description)
    @qid = qid
    @question_type = q_type
    @center_id = cid
    @scheme_description = description
  end
end