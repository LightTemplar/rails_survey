class Center
  attr_reader :id, :kind, :type, :code, :centers

  def initialize(id, kind, type, code)
    @id = id.to_i
    @kind = kind
    @type = type
    @code = code.to_i
  end

  def self.initialize_centers(file)
    @centers = []
    book = Roo::Spreadsheet.open(file, extension: :xlsx)
    centers_sheet = book.sheet('CenterType')
    centers_sheet.drop(1).each do |center|
      @centers.push(Center.new(center[0], center[1], center[2], center[3]))
    end
    @centers
  end

  def self.get_centers
    @centers
  end
end
