require 'scoring/observational/scorer'
require 'scoring/observational/score_utils'

# Scores wide format files
namespace :observational do

  task :initialize, [:folder_name] => :environment do |task, args|
    ScoreUtils.generate_scorers(args[:folder_name])
  end

  # rake observational:score['/path/to/surveys/folder/']
  task :score, [:folder_name] => :environment do |task, args|
    ScoreUtils.reset_score_holders
    scorer = Scorer.new
    scorer.score(args[:folder_name])
  end

  # Sort long files by survey_id before running this task
  task :flip_file_format, [:folder_name] => :environment do |task, args|
    Dir.glob(args[:folder_name] + 'surveys/merged_long/*.csv').each do |filename|
      header = []
      CSV.foreach(filename, encoding: 'iso-8859-1:utf-8') do |row|
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

      csv_file = args[:folder_name] + 'surveys/merged_wide/' + filename.split('/').last
      CSV.open(csv_file, 'wb') do |csv|
        csv << header
        current_survey = nil
        data_row = Array.new(header.size, nil)
        CSV.foreach(filename, encoding: 'iso-8859-1:utf-8') do |row|
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

  task :export_scores, [:folder_name] => :environment do |task, args|
    csv_file = args[:folder_name] + 'scores.csv'
    CSV.open(csv_file, 'wb') do |csv|
      header = %w(survey_id survey_uuid device_label device_user survey_start_time survey_end_time parent_unit_name
                variable_name center_id score_section_name score_sub_section_name unit_score_value unit_score_weight
                score_X_weight sum_unit_score_weight sum_score_X_weight sub_section_score section_score
                center_section_subsection center_section domain sub_domain)
      csv << header
      unit_scores = UnitScore.all.order('center_section_sub_section_name')
      index = 0
      unit_scores.each do |unit_score|
        row = [unit_score.survey_score.survey_id, unit_score.survey_score.survey_uuid, unit_score.survey_score.device_label,
               unit_score.survey_score.device_user, unit_score.survey_score.survey_start_time, unit_score.survey_score.survey_end_time,
               unit_score.unit.name, unit_score.variable.name, unit_score.survey_score.center_id,
               unit_score.unit.score_sub_section.score_section.name, unit_score.unit.score_sub_section.name, unit_score.value, unit_score.unit.weight,
               unit_score.score_weight_product, '', '', '', '', '', '', unit_score.unit.domain, unit_score.unit.sub_domain]
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
