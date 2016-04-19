class GroupScore < Score
  attr :name, :qids
  def initialize(name, ids, center_id, instrument_id, question_type)
    @name = name
    @qids = ids
    @center_id = center_id
    @instrument_id = instrument_id
    @question_type = question_type
  end

end