require 'scoring/crib_bed'

class LookupScheme < ScoringScheme
  attr :crib_beds

  def initialize_cribs(file)
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

  def score(obj)
    return nil if obj.response.blank?
    scores = []
    obj.response.split(',').each_with_index { |res, index|
      if is_number(res)
        crib_score = @crib_beds.find {|crib| crib.age_index == index && crib.hours_in_bed == res.to_f}
        scores.push(crib_score.raw_score) if crib_score
      else
        #TODO process non nil & non-number responses
      end
    }
    if scores.size > 0
      (scores.compact.reduce(:+) / scores.size).round(2)
    else
      'Lookup manual' #TODO ???
    end
  end
end