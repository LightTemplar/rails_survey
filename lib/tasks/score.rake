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
    Dir.glob("/Users/leonardngeno/Desktop/Scoring/surveys/*.csv").each do |filename|
      CSV.foreach(filename) do |row|
        if $. == 1
          header = row
        else
          survey_id_index = header.index('survey_id')
          survey_id = row[survey_id_index] if survey_id_index
          score = Score.create(survey_id: survey_id)
          current_variable = Variable.first
          current_unit = current_variable.unit
          while current_variable do
            variable_identifier = current_variable.name
            variable_index = header.index(variable_identifier)
            chosen_variable_result = 0
            chosen_variable = nil
            while chosen_variable_result == 0 do
              if variable_index
                variable_response = row[variable_index].to_i
                chosen_variables = current_unit.variables.where("name = ? AND value = ?", variable_identifier, variable_response) if variable_response       
                chosen_variable = chosen_variables[0] unless chosen_variables.blank?
                chosen_variable_result = chosen_variable.result.to_i if chosen_variable
                break unless chosen_variable
                if chosen_variable_result == 0
                  variable_index = header.index(chosen_variable.result)
                  variable_identifier = chosen_variable.result
                  relevant_variables = Variable.where(name: variable_identifier)
                  intersection = current_unit.variables & relevant_variables
                  if intersection.blank? && !relevant_variables[0].reference_unit_name
                    res = 0
                    while res == 0 do
                      parent_unit = Variable.where(name: variable_identifier).try(:first).try(:unit)
                      variable_response = row[variable_index].to_i
                      chosen_variables = parent_unit.variables.where("name = ? AND value = ?", variable_identifier, variable_response) if variable_response       
                      chosen_variable = chosen_variables[0] unless chosen_variables.blank?
                      chosen_variable_result = chosen_variable.result.to_i if chosen_variable
                      res = chosen_variable_result
                      if res == 0
                        variable_index = header.index(chosen_variable.result)
                        variable_identifier = chosen_variable.result
                      end
                    end
                  end
                end
              else
                break
              end
            end
            if chosen_variable_result != 0
              UnitScore.create(score_id: score.id, unit_id: current_unit.id, value: chosen_variable_result)
            end
            if chosen_variable && chosen_variable.reference_unit_name
              current_unit = Unit.where(name: chosen_variable.reference_unit_name).try(:first)
              current_variable = current_unit.variables.where(name: chosen_variable.next_variable).try(:first) if current_unit
            elsif chosen_variable && chosen_variable.next_variable == "END"
              current_variable = nil
              current_unit = nil
            elsif chosen_variable == nil
              last_variable_in_current_unit = current_unit.variables.where(result: "1.0").try(:first)
              if last_variable_in_current_unit.reference_unit_name
                current_unit = Unit.where(name: last_variable_in_current_unit.reference_unit_name).try(:first)
                current_variable = current_unit.variables.where(name: last_variable_in_current_unit.next_variable).try(:first) if current_unit
              else
                current_variable = Variable.where(name: last_variable_in_current_unit.next_variable).try(:first)
                current_unit = current_variable.unit if current_variable
              end
            else
              current_variable = Variable.where("name = ? AND unit_id != ?", chosen_variable.next_variable, current_unit.id).try(:first)
              current_unit = current_variable.unit if current_variable
            end
          end
        end
      end  
    end
  end
  
  task export_scores: :environment do
    csv_file = "/Users/leonardngeno/Desktop/Scoring/scores.csv"
    CSV.open(csv_file, "wb") do |csv|
      header = ['survey_id', 'unit_score_id', 'parent_score_id', 'parent_unit_id', 'parent_unit_name', 'unit_score_value']
      csv << header
      Score.all.each do |score|
        score.unit_scores.each do |unit_score|
          row = [unit_score.score.survey_id, unit_score.id, unit_score.score_id, unit_score.unit.id, unit_score.unit.name, unit_score.value]
          csv << row
        end
      end
    end
  end
  
end