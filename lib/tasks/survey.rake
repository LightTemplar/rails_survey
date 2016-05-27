require 'scoring/scores/score'
require 'scoring/scores/group_score'
require 'scoring/scores/roster_score'
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
    book = Roo::Spreadsheet.open(base_dir + 'NonObsScoring-ForLeo.xlsx', extension: :xlsx)
    scoring_sheet = book.sheet('Scoring')

    # Initialize crib beds and centers
    CribBed.initialize_cribs(base_dir + 'NonObsScoring-ForLeo.xlsx')
    Center.initialize_centers(base_dir + 'NonObsScoring-ForLeo.xlsx')

    # Generate scoring schemes
    scoring_sheet.drop(1).each do |row|
      scoring_scheme = SchemeGenerator.generate(row)
      if scoring_scheme.nil?
        next
      elsif scoring_scheme.class == Array
        scoring_schemes.concat(scoring_scheme)
      elsif scoring_scheme.question_type == 'Roster'
        roster_schemes.push(scoring_scheme)
      elsif scoring_scheme.description == 'Group average'
        group_score_schemes.push(scoring_scheme)
      else
        scoring_schemes.push(scoring_scheme)
      end

      # === Begin Roster ===
      # if row[2].strip == 'Roster' && row[6].strip == 'Simple search'
      #   scoring_scheme = SearchScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7])
      #   white_space_index = row[5].index(' ')
      #   scoring_scheme.word_bank = row[5][0..white_space_index].strip
      #   scoring_scheme.key_score_mapping = row[5][white_space_index+1..row[5].length-1]
      #   roster_schemes.push(scoring_scheme)
      #   puts scoring_scheme.inspect
      #   scoring_scheme = nil
      # end
      # === End Roster ===

    end

    # Parse responses and create score objects
    header = []
    response_scores = []
    scores = []
    Dir.glob(base_dir + 'surveys/*.csv').each do |filename|
      CSV.foreach(filename) do |row|
        if $. == 1
          header = row
        else
          qid = header.index('qid') ? row[header.index('qid')] : nil
          if qid
            survey_id = header.index('survey_id') ? row[header.index('survey_id')] : nil
            survey_uuid = header.index('survey_uuid') ? row[header.index('survey_uuid')] : nil
            device_label = header.index('device_label') ? row[header.index('device_label')] : nil
            device_user = header.index('device_user_username') ? row[header.index('device_user_username')] : nil
            center_id = header.index('Center ID') ? row[header.index('Center ID')] : nil
            instrument_id = header.index('instrument_id') ? row[header.index('instrument_id')] : nil
            question_type = header.index('question_type') ? row[header.index('question_type')] : nil
            response = header.index('response') ? row[header.index('response')] : nil
            response_scores.push(Score.new(qid, survey_id, survey_uuid, device_label, device_user, center_id, instrument_id,
                      question_type, response))
          end
        end
      end
    end

    group_identifiers = group_score_schemes.collect { |item| item.qids }.flatten
    group_response_scores = []

    # Score individual responses
    response_scores.each do |sc|
      scheme = scoring_schemes.find{|obj| obj.qid == sc.qid && obj.question_type == sc.question_type}
      if scheme #Only score those that have scoring schemes
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

      elsif group_identifiers.find{|ob| ob == sc.qid}
        group_response_scores.push(sc)
      end
    end

    # Score group responses
    Center.get_centers.each do |center|
      group_score_schemes.each do |group_scheme|
        center_grs = group_response_scores.find_all{|grs| grs.center_id == center.id}
        score_group = GroupScore.new(group_scheme.name, group_scheme.qids, center.id,
                                     center_grs.try(:first).try(:instrument_id),
                                     center_grs.try(:first).try(:question_type))
        score_group.raw_score = group_scheme.score(center_grs)
        score_group.scheme_description = group_scheme.name
        score_group.weight = group_scheme.assign_weight
        score_group.domain = group_scheme.domain
        score_group.sub_domain = group_scheme.sub_domain
        scores.push(score_group)
      end
    end

    # === Rosters ===
    Dir.glob(base_dir + 'Rosters_Phase_II/*.xlsx').each do |filename|
      center_id = filename.split('/').last.gsub(/[^\d]/, '')
      roster_book = Roo::Spreadsheet.open(filename, extension: :xlsx)
      children_sheet = roster_book.sheet('Niños y Niñas')

      # child section
      previous_care_scheme = roster_schemes.find{|scheme| scheme.description == 'Simple search' &&
          scheme.question_type == 'Roster'}
      scores.push(previous_care_scheme.generate_previous_care_score(children_sheet, center_id.to_i))
      age_and_school_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
          scheme.question_text == 'School'}
      scores.push(age_and_school_scheme.get_age_school_score(children_sheet, center_id.to_i))
      vaccination_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
          scheme.question_text == 'Vaccinations'}
      scores.push(vaccination_scheme.get_vaccination_score(children_sheet, center_id.to_i))

      # staff section
      staff_sheet = roster_book.sheet('Personal') #TODO Might not support opening sheets concurrently
      group_assignment_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
        scheme.question_text == 'Group Assignment'}
      scores << group_assignment_scheme.calculate_staff_score(staff_sheet, center_id.to_i, 14)
      shift_per_week = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
          scheme.question_text == '# Shifts/Week'}
      scores << shift_per_week.calculate_staff_score(staff_sheet, center_id.to_i, 11)
      number_of_groups = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
        scheme.question_text == '# Groups worked with'}
      scores << number_of_groups.calculate_staff_score(staff_sheet, center_id.to_i, 14, 15)
      hours_per_week_scheme = roster_schemes.find{|scheme| scheme.respond_to?(:question_text) &&
          scheme.question_text == '# Hours/Week'}
      scores << hours_per_week_scheme.get_weekly_hours_score(staff_sheet, center_id.to_i, 12)
    end

    # TODO
    # next

    puts scores.size

    # Export scores to csv file
    csv_file = base_dir + 'scores.csv'
    CSV.open(csv_file, 'wb') do |csv|
      header = %w[center_id instrument_id survey_id survey_uuid device_label device_user qid question_type
                scoring_description domain sub_domain response weight raw_score weighted_score domain_score
                sub_domain_1_score sub_domain_2_score sub_domain_3_score sub_domain_4_score
                sub_domain_5_score sub_domain_6_score sub_domain_7_score sub_domain_8_score]
      csv << header
      Center.get_centers.each do |center|
        center_scores = scores.find_all{|score| score.center_id == center.id}
        domains = center_scores.map(&:domain).uniq.compact.sort
        domains.each do |domain|
          domain_scores = center_scores.find_all{|score| score.domain == domain}
          domain_scores.each do |score|
            row = [score.center_id, score.instrument_id, score.survey_id, score.survey_uuid, score.device_label,
                   score.device_user, score.qid, score.question_type, score.scheme_description, score.domain,
                   score.sub_domain, score.response, score.weight, score.raw_score, score.weighted_score,
                   '', '', '', '', '', '', '', '', '']
            if score == domain_scores.last
              domain_score = calculate_score(domain_scores)
              domain_score_index = header.index('domain_score')
              row[domain_score_index] = domain_score if domain_score != 0
              sub_domains = []
              domain_scores.each do |dm|
                sub_domains << dm.sub_domain.split(',')
              end
              sub_domains = sub_domains.flatten.compact.uniq.sort
              sub_domains.each do |sub_domain|
                sub_domain_scores = domain_scores.find_all{|sub_score| sub_score.sub_domain.include?(sub_domain)}
                sub_domain_score = calculate_score(sub_domain_scores)
                sub_domain_score_index = header.index('sub_domain_' + sub_domain.strip + '_score')
                row[sub_domain_score_index] = sub_domain_score if sub_domain_score_index != nil && sub_domain_score != 0
              end
            end
            csv << row
          end
        end
      end
    end

  end

  def calculate_score(domain_scores)
    sum_of_weights = domain_scores.map(&:weight).inject(0, &:+)
    sum_of_weighted_scores = domain_scores.reject { |score| score.weighted_score == nil }.map(&:weighted_score)
                                 .inject(0, &:+)
    (sum_of_weighted_scores / sum_of_weights).round(2)
  end

end