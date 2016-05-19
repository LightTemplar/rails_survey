class CribBed
  attr :age, :age_index, :hours_in_bed, :raw_score, :crib_beds

  def initialize(age, index, hours, score)
    @age = age
    @age_index = index
    @hours_in_bed = hours
    @raw_score = score
  end

  def self.initialize_cribs(file)
    @crib_beds = []
    book = Roo::Spreadsheet.open(file, extension: :xlsx)
    crib_bed_sheet = book.sheet('CribBed')
    row_one = crib_bed_sheet.row(1)
    crib_bed_sheet.drop(1).each do |crib_row|
      (1..8).each do |n|
        @crib_beds.push(CribBed.new(row_one[n], n-1, crib_row[0], crib_row[n]))
      end
    end
  end

  def self.get_crib_beds
    @crib_beds
  end

end