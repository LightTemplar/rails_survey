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
        header = row
      else
        row = row
        survey_id_index = header.index('survey_id')
        survey_id = row[survey_id_index] if survey_id_index
        score = Score.create(survey_id: survey_id)
        next_variable = nil
        Unit.all.each do |current_unit|
          variable_index = nil
          variable_identifier = nil
          current_unit.variables.each do |variable|
            variable_identifier = variable.name
            variable_index = header.index(variable_identifier)
            break if variable_index
          end
          next unless variable_index
          if next_variable && current_unit.variables.pluck(:name).include?(next_variable)
            variable_index = header.index(next_variable)
          end
          
          chosen_variable_result = 0
          chosen_variable = nil
          while chosen_variable_result == 0 do
            if variable_index
              variable_response = row[variable_index].to_i
              chosen_variables = current_unit.variables.where("name = ? AND value = ?", variable_identifier, variable_response) if variable_response       
              chosen_variable = chosen_variables[0] unless chosen_variables.blank?
              chosen_variable_result = chosen_variable.result.to_i if chosen_variable
              if chosen_variable_result == 0
                variable_index = header.index(chosen_variable.result)
                variable_identifier = chosen_variable.result
              end
            else
              break
            end
          end
          UnitScore.create(score_id: score.id, unit_id: current_unit.id, value: chosen_variable_result)
          next_variable = chosen_variable.next_variable if chosen_variable
        end
      end
    end  
  end
  
end