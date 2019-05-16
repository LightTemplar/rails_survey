class Scorer

  @current_variable, @current_unit, @variable_identifier, @variable_index, @navigation_result = nil, nil, nil, nil, nil

  def score(folder_name)
    header = []
    Dir.glob(folder_name + 'surveys/*.csv').each do |filename|
      line_counter = 0
      CSV.foreach(filename, encoding: 'iso-8859-1:utf-8') do |row|
        puts 'file name: ' + filename + ' row #: ' + line_counter.to_s + ' with ID: ' + row[0]
        line_counter += 1
        if $. == 1
          header = row
        else
          next if row[0].blank?
          score = create_survey_score(header, row)
          current_sections = ScoreSection.where(instrument_id: row[header.index('instrument_id')]) if header.index('instrument_id')
          set_variables(current_sections[0].variables, true) if current_sections.size > 0
          while @current_unit do
            if @current_variable
              set_variable_identifier(@current_variable, header, true)
            else
              reset_variables
              break
            end
            chosen_variable = nil
            chosen_variable_result = 0
            while chosen_variable_result == 0 do
              if @variable_index
                break if row[@variable_index].blank?
                chosen_variable = @current_unit.variables.where('name = ? AND value = ?', @variable_identifier,
                                  row[@variable_index].to_i).try(:first)
                chosen_variable_result = chosen_variable.result.to_i if chosen_variable
                break unless chosen_variable
                if chosen_variable_result == 0
                  set_variable_identifier(chosen_variable, header)
                end
              else
                break
              end
            end
            if chosen_variable_result == 0
              @current_variable = @current_variable.last_variable_in_unit unless @navigation_result
              next_score_unit(@current_variable)
            else
              create_unit_score(chosen_variable, @current_unit, score)
              next_score_unit(chosen_variable)
            end
          end
        end
      end
    end
  end

  def set_variable_identifier(variable, header, first = false)
    @variable_identifier = first ? variable.name : variable.result
    @variable_index = header.index(@variable_identifier)
    @navigation_result = first ? false : !@current_unit.variables.pluck(:name).include?(@variable_identifier)
  end

  def create_survey_score(header, row)
    survey_id_index = header.index('survey_id')
    survey_id = row[survey_id_index] if survey_id_index
    survey_uuid = row[header.index('survey_uuid')] if header.index('survey_uuid')
    device_label = row[header.index('device_label')] if header.index('device_label')
    device_user = row[header.index('device_user_username')] if header.index('device_user_username')
    survey_start_time = row[header.index('survey_start_time')] if header.index('survey_start_time')
    survey_end_time = row[header.index('survey_end_time')] if header.index('survey_end_time')
    center_id = row[header.index('Center ID')] if header.index('Center ID')
    SurveyScore.create(survey_id: survey_id, survey_uuid: survey_uuid, device_label: device_label,
                       device_user: device_user, survey_start_time: survey_start_time,
                       survey_end_time: survey_end_time, center_id: center_id)
  end

  def create_unit_score(chosen_variable, current_unit, score)
    three_name = score.center_id + '_' +chosen_variable.unit.score_sub_section.score_section.name + '_' +
        chosen_variable.unit.score_sub_section.name
    two_name = score.center_id + '_' + chosen_variable.unit.score_sub_section.score_section.name
    UnitScore.create(survey_score_id: score.id, unit_id: current_unit.id, value: chosen_variable.result.to_i,
                     variable_id: chosen_variable.id, center_section_sub_section_name: three_name,
                     center_section_name: two_name)
  end

  def next_score_unit(variable)
    variable.next_variables ? set_variables(variable) : reset_variables
  end

  def reset_variables
    @current_unit = nil
    @current_variable = nil
  end

  def set_variables(variable, first = false)
    if variable
      @current_variable = first ? variable.first : variable.next_variables.first
      @current_unit = @current_variable.unit if @current_variable
    end
  end

end