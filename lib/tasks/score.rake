namespace :score do
  
  task initialize: :environment do
    book = Roo::Spreadsheet.open('/Users/leonardngeno/Desktop/Scoring/Scoring-ObservationSection.xlsx', extension: :xlsx)
    sheet1 = book.sheet('Sheet1')
    current_unit = Unit.new
    sheet1.drop(1).each do |row|
      unless row[0].nil?
        if current_unit.name == row[0]
          variable = Variable.create(result: row[1], name: row[2], value: row[3], next_variable: row[4], reference_unit_name: row[5], unit_id: current_unit.id)
        else
          unit = Unit.create(name: row[0])
          variable = Variable.create(result: row[1], name: row[2], value: row[3], next_variable: row[4], reference_unit_name: row[5], unit_id: unit.id)
          current_unit = unit
        end
      end
    end 
  end
  
  task score: :environment do
    header = []
    CSV.foreach("/Users/leonardngeno/Desktop/Scoring/wide_csv_1435003735.csv") do |row|
      if $. == 1
        header << row
        puts header
      end
      
    end
  end
  
end