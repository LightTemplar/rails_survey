require 'scoring/scores/score'
require 'scoring/scores/group_score'
require 'scoring/scores/roster_score'
require 'scoring/scores/observational_score'
require 'scoring/crib_bed'
require 'scoring/center'
require 'scoring/scheme_generator'

# Example run: rake survey:score['/path/to/base/dir/']
namespace :survey do
  task :score, [:path_str] do |task_name, args|
    base_dir = args[:path_str]
    scoring_schemes = []
    group_score_schemes = []
    roster_schemes = []
    scores = []
    book = Roo::Spreadsheet.open(base_dir + 'NonObs/NonObsScoringScheme.xlsx', extension: :xlsx)
    scoring_sheet = book.sheet('Scoring')

    # Initialize crib beds and centers
    CribBed.initialize_cribs(base_dir + 'NonObs/NonObsScoringScheme.xlsx')
    Center.initialize_centers(base_dir + 'NonObs/NonObsScoringScheme.xlsx')

    # Generate scoring schemes
    scoring_sheet.drop(1).each do |row|
      scoring_scheme = SchemeGenerator.generate(row)
      if scoring_scheme.nil?
        next
      elsif scoring_scheme.class == Array
        scoring_schemes.concat(scoring_scheme)
      elsif scoring_scheme.question_type.include?('Roster')
        roster_schemes.push(scoring_scheme)
      elsif scoring_scheme.description == 'Group average'
        group_score_schemes.push(scoring_scheme)
      else
        scoring_schemes.push(scoring_scheme)
      end
    end

    # Parse responses and create score objects
    header = %w(qid	short_qid	instrument_id	instrument_version_number
      question_version_number	instrument_title	survey_id	survey_uuid
      device_id	device_uuid	device_label	question_type	question_text
      response	response_labels	special_response	other_response
      response_time_started	response_time_ended	device_user_id
      device_user_username	participant_uuid	participant_type	Center_ID
      survey_label)
    response_scores = []
    # Expects long versions of the export files
    Dir.glob(base_dir + 'NonObs/surveys/*.csv').each do |filename|
      CSV.foreach(filename, encoding:'iso-8859-1:utf-8') do |row|
        if $. == 1
          # header = row
        else
          qid = header.index('qid') ? row[header.index('qid')] : nil
          if qid
            survey_id = header.index('survey_id') ? row[header.index('survey_id')] : nil
            survey_uuid = header.index('survey_uuid') ? row[header.index('survey_uuid')] : nil
            device_label = header.index('device_label') ? row[header.index('device_label')] : nil
            device_user = header.index('device_user_username') ? row[header.index('device_user_username')] : nil
            center_id = header.index('Center_ID') ? row[header.index('Center_ID')] : nil
            instrument_id = header.index('instrument_id') ? row[header.index('instrument_id')] : nil
            question_type = header.index('question_type') ? row[header.index('question_type')] : nil
            response = header.index('response') ? row[header.index('response')] : nil
            response_scores.push(Score.new(qid, survey_id, survey_uuid, device_label,
              device_user, center_id, instrument_id, question_type, response))
          end
        end
      end
    end

    group_identifiers = group_score_schemes.collect { |item| item.qids }.flatten
    group_identifiers = group_identifiers.uniq
    group_response_scores = []

    # Score individual responses
    response_scores.each do |sc|
      scheme = scoring_schemes.find{|obj| obj.qid == sc.qid && obj.question_type == sc.question_type}
      if scheme # Only score those that have scoring schemes
        if scheme.description == 'Indexed' || scheme.description == 'Matching'
          reference = nil
          if scheme.reference_qid
            reference = response_scores.find{|obj| obj.qid == scheme.reference_qid && obj.center_id == sc.center_id}
            if reference.nil?
              #TODO Why is it nil on some instances
            end
          end
          sc.raw_score = scheme.score(sc, reference)
        else
          sc.raw_score = scheme.score(sc)
        end
        sc.scheme_description = scheme.description
        sc.weight = scheme.assign_weight(sc.center_id)
        sc.domain = scheme.domain
        sc.sub_domain = scheme.sub_domain
        scores.push(sc)
      end
      # Add to group schemes if it qualifies
      if group_identifiers.include?(sc.qid)
        group_response_scores.push(sc)
      end
    end
    puts 'individual scores added: ' + scores.size.to_s

    # Score group responses
    center_ids = group_response_scores.collect { |grs| grs.center_id }.uniq
    center_ids.each do |id|
      center = Center.get_centers.find_all { |ct| ct.id == id }.first
      if center
        group_score_schemes.each do |group_scheme|
          center_grs = []
          group_scheme.qids.each do |qid|
            cgr = group_response_scores.find_all {|grs| grs.center_id == center.id && grs.qid == qid}
            center_grs = center_grs + cgr
          end
          score_group = GroupScore.new(group_scheme.name, group_scheme.qids, center.id,
            center_grs.try(:first).try(:instrument_id), center_grs.try(:first).try(:question_type))
          score_group.raw_score = group_scheme.score(center_grs)
          score_group.scheme_description = group_scheme.name
          score_group.weight = group_scheme.assign_weight
          score_group.domain = group_scheme.domain
          score_group.sub_domain = group_scheme.sub_domain
          scores.push(score_group)
        end
      end
    end
    puts 'group scores added: ' + scores.size.to_s

    # Optimize role response search array
    role_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) && scheme.question_text == 'Name of Role'}
    role_response_scores = []
    role_scheme.qid.split(',').each do |qid|
      role_response_scores.concat(response_scores.find_all{|rs| rs.qid == qid})
    end

    # Write manual scores to file
    file = base_dir + 'NonObs/manual_scores.csv'
    CSV.open(file, 'wb') do |csv|
      csv << %w(center_id instrument_id survey_id survey_uuid device_label device_user
        qid question_type scoring_description domain sub_domain response weight raw_score)
      csv << []
      scores.each do |score|
        if score.raw_score == 'manual'
          row = [score.center_id, score.instrument_id, score.survey_id, score.survey_uuid, score.device_label, score.device_user, score.qid, score.question_type, score.scheme_description, score.domain, score.sub_domain, score.response, score.weight, score.raw_score]
          csv << row
        end
      end
    end

    # === Rosters ===
    Dir.glob(base_dir + 'NonObs/Rosters/*.xlsx').each do |filename|
      center_id = filename.split('/').last.gsub(/[^\d]/, '')
      unless center_id.blank?
        roster_book = Roo::Spreadsheet.open(filename, extension: :xlsx)
        children_sheet = roster_book.sheet(roster_book.sheets[1]) #roster_book.sheet('Niños y Niñas')

        # child section
        previous_care_scheme = roster_schemes.find{|scheme| scheme.description == 'Simple search' &&
            scheme.question_type == 'Roster'}
        pcs_score = previous_care_scheme.generate_previous_care_score(children_sheet, center_id.to_i)
        scores.push(pcs_score)
        age_and_school_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
            scheme.question_text == 'School'}
        aass_score = age_and_school_scheme.get_age_school_score(children_sheet, center_id.to_i)
        scores.push(aass_score)
        vaccination_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
            scheme.question_text == 'Vaccinations'}
        vs_score = vaccination_scheme.get_vaccination_score(children_sheet, center_id.to_i)
        scores.push(vs_score)
        lag_time_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
          scheme.question_text == 'Arrival-Assignment lag time'}
        lts_score = lag_time_scheme.get_lag_time_score(children_sheet, center_id.to_i)
        scores.push(lts_score)

        # staff section
        staff_sheet = roster_book.sheet('Personal') # TODO Might not support opening sheets concurrently
        group_assignment_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
          scheme.question_text == 'Group Assignment'}
        scores << group_assignment_scheme.calculate_staff_score(staff_sheet, center_id.to_i, 14)
        shift_per_week = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
            scheme.question_text == '# Shifts/Week'}
        scores << shift_per_week.calculate_staff_score(staff_sheet, center_id.to_i, 11)
        number_of_groups = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
          scheme.question_text == '# groups they have worked with in time at center'}
        scores << number_of_groups.calculate_staff_score(staff_sheet, center_id.to_i, 14, 15)
        hours_per_week_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
            scheme.question_text == '# Hours/Week'}
        scores << hours_per_week_scheme.get_weekly_hours_score(staff_sheet, center_id.to_i, 12)
        name_of_role = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
            scheme.question_text == 'Name of Role'}
        roles = []
        name_of_role.qid.split(',').each do |qid|
          roles.concat(role_response_scores.find_all{|rs| rs.center_id == center_id.to_i && rs.qid == qid})
        end
        scores << name_of_role.match_roles(staff_sheet, center_id.to_i, 4, roles)
      end
    end
    puts 'roster scores added: ' + scores.size.to_s

    # Integrate manually scored ones

    manual_score_book =  Roo::Spreadsheet.open(base_dir + 'NonObs/Manual_Scoring_V2.xlsx', extension: :xlsx)
    manual_score_sheet = manual_score_book.sheet('ManualScores')
    manual_score_sheet.drop(1).each do |row|
      if row[0] && row[2] && row[6] && row[13] != 'manual' && !row[13].blank?
        selected_score = scores.find_all { |score|
          # puts "score: #{score.inspect}"
          score.center_id == row[0].to_i &&
          score.survey_id == row[2].to_i.to_s && score.qid == row[6] && score.raw_score == 'manual'
        }
        selected_score.each do |score|
          score.raw_score = row[13].to_i
        end
      end
    end

    # Integrate observational scores

    options = {:encoding => 'UTF-8', :skip_blanks => true}
    csv_header = []
    CSV.foreach(base_dir + 'Obs/scores.csv', options).with_index do |row, line|
      if line == 0
        csv_header = row
      end
      qid = csv_header.index('variable_name') ? row[csv_header.index('variable_name')] : nil
      survey_id = csv_header.index('survey_id') ? row[csv_header.index('survey_id')] : nil
      survey_uuid = csv_header.index('survey_uuid') ? row[csv_header.index('survey_uuid')] : nil
      device_label = csv_header.index('device_label') ? row[csv_header.index('device_label')] : nil
      device_user = csv_header.index('device_user') ? row[csv_header.index('device_user')] : nil
      center_id = csv_header.index('center_id') ? row[csv_header.index('center_id')] : nil
      raw_score = csv_header.index('unit_score_value') ? row[csv_header.index('unit_score_value')] : nil
      weight = csv_header.index('unit_score_weight') ? row[csv_header.index('unit_score_weight')] : nil
      domain = csv_header.index('domain') ? row[csv_header.index('domain')] : nil
      if qid && center_id
        scores << ObservationalScore.new(qid, survey_id, survey_uuid, device_label,
          device_user, center_id, raw_score, weight, domain)
      end
    end
    puts 'observational scores added: ' + scores.size.to_s

    # Export scores to csv file
    all_center_scores = []
    all_domain_scores = {1 => [], 2 => [], 3 => [], 4 => [], 5 => [], 6 => [], 7 => [], 8 => [], 9 => [], 10 => []}
    csv_file = base_dir + 'QCUALS_SCORES.csv'
    CSV.open(csv_file, 'wb') do |csv|
      header = %w(center_id instrument_id survey_id survey_uuid device_label
        device_user qid question_type scoring_description domain weight
        raw_score weighted_score domain_score domain_weight weighted_domain_score
        center_score domain_1_avg domain_2_avg domain_3_avg domain_4_avg
        domain_5_avg domain_6_avg domain_7_avg domain_8_avg domain_9_avg
        domain_10_avg center_score_avg)
                # subdomain sub_domain_1_score sub_domain_2_score sub_domain_3_score sub_domain_4_score
                # sub_domain_5_score sub_domain_6_score sub_domain_7_score sub_domain_8_score]
      csv << header
      Center.get_centers.each do |center|
        center_scores = []
        scores.each do |score|
          center_scores << score if score.is_a?(Score) && score.center_id == center.id
        end
        domains = center_scores.map(&:domain).uniq.compact.sort
        weighted_center_score_sum = 0
        weights_sum = 0
        domain_weights = { 1 => 2, 2 => 3, 3 => 4, 4 => 4, 5 => 3, 6 => 5, 7 => 5, 8 => 5, 9 => 3, 10 => 3 }
        domains.each_with_index { |domain, index|
          domain_scores = center_scores.find_all{|score| score.domain == domain}
          domain_scores.each do |score|
            reported_score = (score.raw_score.class == String && score.raw_score == 'manual') ? nil : score.raw_score
            row = [score.center_id, score.instrument_id, score.survey_id, score.survey_uuid, score.device_label,
                   score.device_user, score.qid, score.question_type, score.scheme_description, score.domain,
                   score.weight, reported_score, score.weighted_score, '', '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '']
                   #score.sub_domain, '', '', '', '', '', '', '', '', '', '']
            if score == domain_scores.last
              domain_score = calculate_score(domain_scores)
              if domain_score && domain_score != 0
                row[header.index('domain_score')] = domain_score
                row[header.index('domain_weight')] = domain_weights[domain]
                row[header.index('weighted_domain_score')] = (domain_score * domain_weights[domain]).round(2)
                weighted_center_score_sum += (domain_score * domain_weights[domain])
                weights_sum += domain_weights[domain]
                old_value = all_domain_scores[domain]
                all_domain_scores[domain] = old_value << domain_score
              end

              # TODO Will be added later
              # sub_domains = []
              # domain_scores.each do |dm|
              #   sub_domains << dm.sub_domain.split(',')
              # end
              # sub_domains = sub_domains.flatten.compact.uniq.sort
              # sub_domains.each do |sub_domain|
              #   sub_domain_scores = domain_scores.find_all{|sub_score| sub_score.sub_domain.include?(sub_domain)}
              #   sub_domain_score = calculate_score(sub_domain_scores)
              #   sub_domain_score_index = header.index('sub_domain_' + sub_domain.strip + '_score')
              #   row[sub_domain_score_index] = sub_domain_score if sub_domain_score_index != nil && sub_domain_score != 0
              # end

            end
            if index == domains.size - 1 && score == domain_scores.last
              center_score_index = header.index('center_score')
              if center_score_index && weights_sum != 0
                cnt_score = (weighted_center_score_sum/weights_sum).round(2)
                row[center_score_index] =  cnt_score
                all_center_scores << cnt_score
              end
            end
            csv << row
          end
          }
      end
      row = Array.new(28, '')
      row[header.index('center_score_avg')] = (all_center_scores.inject(0, &:+) / all_center_scores.size).round(2) unless all_center_scores.empty?
      all_domain_scores.each do |key, array|
        row[header.index('domain_' + key.to_s + '_avg')] = (array.inject(0, &:+) / array.size).round(2) unless array.empty?
      end
      csv << row
    end

  end

  def calculate_score(domain_scores)
    sanitized_scores = domain_scores.reject { |score| score.weighted_score == nil }
    return nil if sanitized_scores.size == 0
    sum_of_weights = sanitized_scores.map(&:weight).inject(0, &:+)
    sum_of_weighted_scores = sanitized_scores.map(&:weighted_score).inject(0, &:+)
    (sum_of_weighted_scores / sum_of_weights).round(2)
  end

end
