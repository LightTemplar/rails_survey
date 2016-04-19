require 'scoring/center'

class CalculationScheme < ScoringScheme
  attr :centers

  def self.initialize_centers(file)
    @centers = []
    book = Roo::Spreadsheet.open(file, extension: :xlsx)
    centers_sheet = book.sheet('CenterType')
    centers_sheet.drop(1).each do |center|
      @centers.push(Center.new(center[0], center[1], center[2], center[3]))
    end
    @centers
  end

  def self.centers
    @centers
  end

  #TODO roster scoring
end