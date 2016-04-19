class GroupScheme < ScoringScheme
  attr :qids, :index

  def qids=(ids)
    @qids = ids.split
  end
  
  def index=(index)
    @index = index
  end
end