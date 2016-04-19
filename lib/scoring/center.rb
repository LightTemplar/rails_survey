class Center
  attr :id, :kind, :type, :code

  def initialize(id, kind, type, code)
    @id = id.to_i
    @kind = kind
    @type = type
    @code = code.to_i
  end

end