namespace :score do
  
  task initialize: :environment do
    book = Roo::Spreadsheet.open('/Users/leonardngeno/Desktop/Scoring/Scoring-ObservationSection-v4.xlsx', extension: :xlsx)
    sheet1 = book.sheet('Sheet1')
    current_unit = Unit.new
    current_section = ScoreSection.new
    current_sub_section = ScoreSubSection.new
    sheet1.drop(1).each do |row|
      unless row[0].nil?
        if current_unit.name == row[0]
          variable = Variable.create(result: row[1], name: row[2], value: row[3], next_variable: row[4], next_unit_name: row[5], unit_id: current_unit.id)
        else
          if current_section.name == row[7]
            unless current_sub_section.name == row[8]
             current_sub_section = ScoreSubSection.create(name: row[8], score_section_id: current_section.id)  
            end
          else
            current_section = ScoreSection.create(name: row[7], instrument_id: row[9])
            current_sub_section = ScoreSubSection.create(name: row[8], score_section_id: current_section.id)
          end 
          unit = Unit.create(name: row[0], weight: row[6], score_sub_section_id: current_sub_section.id)
          variable = Variable.create(result: row[1], name: row[2], value: row[3], next_variable: row[4], next_unit_name: row[5], unit_id: unit.id)
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
          survey_uuid = row[header.index('survey_uuid')] if header.index('survey_uuid')
          device_label = row[header.index('device_label')] if header.index('device_label')
          device_user = row[header.index('device_user_username')] if header.index('device_user_username')
          survey_start_time = row[header.index('survey_start_time')] if header.index('survey_start_time')
          survey_end_time = row[header.index('survey_end_time')] if header.index('survey_end_time')
          center_id = row[header.index('Center ID')] if header.index('Center ID')
          score = SurveyScore.create(survey_id: survey_id, survey_uuid: survey_uuid, device_label: device_label, 
            device_user: device_user, survey_start_time: survey_start_time, survey_end_time: survey_end_time, center_id: center_id)
          
          instrument_id_index = header.index('instrument_id') 
          instrument_id = row[instrument_id_index] if instrument_id_index
          current_sections = ScoreSection.where(instrument_id: instrument_id) if instrument_id
          current_variable = current_sections[0].variables.first        
          current_unit = current_variable.unit if current_variable
          previous_unit = nil
          
          while current_unit do
            variable_identifier = current_variable.name
            variable_index = header.index(variable_identifier)
            chosen_variable = nil
            chosen_variable_result = 0
            navigation_result = false
            while chosen_variable_result == 0 do
               if variable_index
                 break if row[variable_index].blank?
                 variable_response = row[variable_index].to_i
                 chosen_variable = current_unit.variables.where("name = ? AND value = ?", variable_identifier, variable_response).try(:first) if variable_response       
                 chosen_variable_result = chosen_variable.result.to_i if chosen_variable
                 break unless chosen_variable
                 if chosen_variable_result == 0
                   variable_identifier = chosen_variable.result
                   variable_index = header.index(variable_identifier)
                   navigation_result = !current_unit.variables.pluck(:name).include?(variable_identifier)
                 end
               else
                 break
               end
            end
            if chosen_variable_result == 0
              previous_unit = current_unit
              current_variable = current_variable.last_variable_in_unit unless navigation_result
              if current_variable.next_variables
                current_variable = current_variable.next_variables.first
                current_unit = current_variable.unit
              else
                current_unit = nil
                current_variable = nil
              end
            else
              three_name = (center_id.to_i).to_s + "_" + chosen_variable.unit.score_sub_section.score_section.name + "_" + (chosen_variable.unit.score_sub_section.name.to_i).to_s
              two_name = (center_id.to_i).to_s + "_" + chosen_variable.unit.score_sub_section.score_section.name
              UnitScore.create(survey_score_id: score.id, unit_id: current_unit.id, value: chosen_variable.result.to_i, 
                variable_id: chosen_variable.id, center_section_sub_section_name: three_name, center_section_name: two_name)
              if chosen_variable.next_variables
                previous_unit = current_unit
                current_variable = chosen_variable.next_variables.first
                current_unit = current_variable.unit
              else
                previous_unit = current_unit
                current_unit = nil
                current_variable = nil
              end
            end
            if current_unit && current_unit.score_sub_section.score_section != previous_unit.score_sub_section.score_section
              unless current_unit.score_sub_section.score_section.name == "D"
                current_unit = nil
                current_variable = nil
              end
            end
          end
        end
      end  
    end
  end
  
  task export_scores: :environment do
    csv_file = "/Users/leonardngeno/Desktop/Scoring/scores.csv"
    CSV.open(csv_file, "wb") do |csv|
      header = ['survey_id', 'survey_uuid', 'device_label', 'device_user', 'survey_start_time', 'survey_end_time', 'parent_unit_name', 
        'variable_name', 'center_id', 'score_section_name', 'score_sub_section_name' , 'unit_score_value', 'unit_score_weight', 
        'score_X_weight', 'sum_unit_score_weight', 'sum_score_X_weight', 'sub_section_score', 'section_score', 'center_section_subsection', 'center_section']
      
      csv << header
      unit_scores = UnitScore.all.order('center_section_sub_section_name')
      index = 0
      unit_scores.each do |unit_score|
        row = [unit_score.survey_score.survey_id, unit_score.survey_score.survey_uuid, unit_score.survey_score.device_label,
          unit_score.survey_score.device_user, unit_score.survey_score.survey_start_time, unit_score.survey_score.survey_end_time,
          unit_score.unit.name, unit_score.variable.name, unit_score.survey_score.center_id,
          unit_score.unit.score_sub_section.score_section.name, unit_score.unit.score_sub_section.name, unit_score.value, unit_score.unit.weight,
          unit_score.score_weight_product, '', '', '', '', '', '']
        if index + 1 < unit_scores.length
          if unit_score.center_section_sub_section_name != unit_scores[index+1].center_section_sub_section_name
            row[header.index('center_section_subsection')] = unit_score.center_section_sub_section_name
            row[header.index('sum_unit_score_weight')] = unit_score.unit_weights_sum
            row[header.index('sum_score_X_weight')] = unit_score.score_weight_product_sum
            row[header.index('sub_section_score')] = unit_score.sub_section_score
          end
          if unit_score.center_section_name != unit_scores[index+1].center_section_name
            row[header.index('center_section')] = unit_score.center_section_name
            row[header.index('section_score')] = unit_score.section_score
          end
        end
        csv << row
        index += 1
      end
    end
  end
  
end