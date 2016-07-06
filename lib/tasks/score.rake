namespace :score do
  
  task initialize: :environment do
    book = Roo::Spreadsheet.open('/Users/leonardngeno/Desktop/Scoring/ObsScoringScheme.xlsx', extension: :xlsx)
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
          unit = Unit.create(name: row[0], weight: row[6], score_sub_section_id: current_sub_section.id, domain: row[10])
          variable = Variable.create(result: row[1], name: row[2], value: row[3], next_variable: row[4], next_unit_name: row[5], unit_id: unit.id)
          current_unit = unit
        end
      end
    end 
  end

  # Sort long files by survey_id before running this task
  task flip_file_format: :environment do
    Dir.glob('/Users/leonardngeno/Desktop/Scoring/surveys/merged_long/*.csv').each do |filename|
      header = []
      CSV.foreach(filename, encoding:'iso-8859-1:utf-8') do |row|
        if $. == 1
          header = row
          header.delete('qid')
          header.delete('short_qid')
          header.delete('instrument_version_number')
          header.delete('question_version_number')
          header.delete('instrument_title')
          header.delete('response_labels')
          header.delete('special_response')
          header.delete('other_response')
          header.delete('survey_label')
        else
          header << row[0] unless header.index(row[0])
        end
      end

      csv_file = '/Users/leonardngeno/Desktop/Scoring/surveys/merged_wide/' + filename.split('/').last
      CSV.open(csv_file, 'wb') do |csv|
        csv << header
        current_survey = nil
        data_row = Array.new(header.size, nil)
        CSV.foreach(filename, encoding:'iso-8859-1:utf-8') do |row|
          if $. != 1
            instrument_id = header.index('instrument_id')
            if row[6] == current_survey
              data_row = update_data_row(data_row, header, row)
            else
              csv << data_row if data_row.compact.size != 0
              data_row = update_data_row(Array.new(header.size, nil), header, row)
              current_survey = row[6]
            end
          end
        end
      end
    end
  end
  
  task score: :environment do
    header = []
    Dir.glob('/Users/leonardngeno/Desktop/Scoring/surveys/*.csv').each do |filename|
      puts filename
      line_counter = 0
      CSV.foreach(filename, encoding:'iso-8859-1:utf-8') do |row|
        puts 'row #: ' + line_counter.to_s + ' with ID: ' + row[0]
        line_counter += 1
        if $. == 1
          header = row
        else
          if row[0].blank?
            next
          end
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
          current_variable = current_sections[0].variables.first if current_sections.size > 0
          current_unit = current_variable.unit if current_variable

          while current_unit do
            if current_variable
              variable_identifier = current_variable.name
              variable_index = header.index(variable_identifier)
            else
              current_unit = nil
              break
            end
            chosen_variable = nil
            chosen_variable_result = 0
            navigation_result = false
            while chosen_variable_result == 0 do
               if variable_index
                 break if row[variable_index].blank?
                 variable_response = row[variable_index].to_i
                 chosen_variable = current_unit.variables.where('name = ? AND value = ?', variable_identifier, variable_response).try(:first) if variable_response
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
              current_variable = current_variable.last_variable_in_unit unless navigation_result
              if current_variable.next_variables
                current_variable = current_variable.next_variables.first
                current_unit = current_variable.unit
              else
                current_unit = nil
                current_variable = nil
              end
            else
              three_name = (center_id.to_i).to_s + '_' + chosen_variable.unit.score_sub_section.score_section.name + '_' + (chosen_variable.unit.score_sub_section.name.to_i).to_s
              two_name = (center_id.to_i).to_s + '_' + chosen_variable.unit.score_sub_section.score_section.name
              UnitScore.create(survey_score_id: score.id, unit_id: current_unit.id, value: chosen_variable.result.to_i, 
                variable_id: chosen_variable.id, center_section_sub_section_name: three_name, center_section_name: two_name)
              if chosen_variable.next_variables
                current_variable = chosen_variable.next_variables.first
                current_unit = current_variable.unit if current_variable
              else
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
    csv_file = '/Users/leonardngeno/Desktop/Scoring/scores.csv'
    CSV.open(csv_file, "wb") do |csv|
      header = ['survey_id', 'survey_uuid', 'device_label', 'device_user', 'survey_start_time', 'survey_end_time', 'parent_unit_name', 
        'variable_name', 'center_id', 'score_section_name', 'score_sub_section_name' , 'unit_score_value', 'unit_score_weight', 
        'score_X_weight', 'sum_unit_score_weight', 'sum_score_X_weight', 'sub_section_score', 'section_score', 'center_section_subsection',
                'center_section', 'domain']
      
      csv << header
      unit_scores = UnitScore.all.order('center_section_sub_section_name')
      index = 0
      unit_scores.each do |unit_score|
        row = [unit_score.survey_score.survey_id, unit_score.survey_score.survey_uuid, unit_score.survey_score.device_label,
          unit_score.survey_score.device_user, unit_score.survey_score.survey_start_time, unit_score.survey_score.survey_end_time,
          unit_score.unit.name, unit_score.variable.name, unit_score.survey_score.center_id,
          unit_score.unit.score_sub_section.score_section.name, unit_score.unit.score_sub_section.name, unit_score.value, unit_score.unit.weight,
          unit_score.score_weight_product, '', '', '', '', '', '', unit_score.unit.domain]
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

  def update_data_row(data_row, header, row)
    data_row[header.index(row[0])] = row[13]
    data_row[header.index('instrument_id')] = row[2]
    data_row[header.index('survey_id')] = row[6]
    data_row[header.index('survey_uuid')] = row[7]
    data_row[header.index('device_id')] = row[8]
    data_row[header.index('device_uuid')] = row[9]
    data_row[header.index('device_label')] = row[10]
    data_row[header.index('question_type')] = row[11]
    data_row[header.index('question_text')] = row[12]
    data_row[header.index('device_user_id')] = row[19]
    data_row[header.index('device_user_username')] = row[20]
    data_row[header.index('Center ID')] = row[23]
    data_row[header.index('response_time_started')] = row[17]
    data_row[header.index('response_time_ended')] = row[18]
    data_row
  end
  
end